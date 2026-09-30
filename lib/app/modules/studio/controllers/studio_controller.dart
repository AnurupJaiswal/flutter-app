import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/app/modules/studio/data/pixo_event.dart';
import 'package:lala_ai/app/modules/studio/data/pixo_message.dart';
import 'package:lala_ai/app/modules/studio/data/pixo_sse_repository.dart';
import 'package:lala_ai/utils/common_methods.dart';

// ── Stream state machine ──────────────────────────────────────────────────────

enum PixoStreamState {
  idle,
  start,
  contextReady,
  toolResult,
  generating,
  completed,
  error,
  entitlementDenied,
  usageLimitReached,
  providerUnavailable,
  contextUnavailable,
  cancelled,
  reconnecting,
}

// ── Controller ────────────────────────────────────────────────────────────────

/// Manages the full Pixo chat lifecycle.
///
/// ALL network calls go through [PixoSseRepository].  There is no legacy
/// StudioChatRepository dependency — the Pixo SSE contract is the only API.
///
/// Conversation identity is established by the `START` SSE event, not by a
/// pre-flight REST call.
class StudioController extends GetxController {
  final PixoSseRepository pixoRepo;

  StudioController({required this.pixoRepo});

  // ── Conversation state ────────────────────────────────────────────────────
  final chats = <ChatSessionModel>[].obs;
  final activeChat = Rxn<ChatSessionModel>();

  /// Pixo-aware message list (exclusive rendering model for the Studio view).
  final pixoMessages = <PixoMessage>[].obs;

  final isChatsLoading = false.obs;
  final searchQuery = ''.obs;

  // ── Stream state machine ──────────────────────────────────────────────────
  final streamState = PixoStreamState.idle.obs;

  bool get isAiThinkingValue =>
      streamState.value != PixoStreamState.idle &&
      streamState.value != PixoStreamState.completed &&
      streamState.value != PixoStreamState.error &&
      streamState.value != PixoStreamState.cancelled &&
      streamState.value != PixoStreamState.entitlementDenied &&
      streamState.value != PixoStreamState.usageLimitReached &&
      streamState.value != PixoStreamState.providerUnavailable &&
      streamState.value != PixoStreamState.contextUnavailable;

  // ── SSE correlation keys from START event ─────────────────────────────────
  int? _activeConversationId;
  int? _activeMessageId;

  // ── Entitlement event data (for upsell modal) ─────────────────────────────
  final entitlementMessage = ''.obs;
  final requiredPlan = Rxn<String>();

  // ── Cancellation handles ──────────────────────────────────────────────────
  CancelToken? _sseCancel;
  StreamSubscription<PixoEvent>? _sseSub;

  // ── UI controllers ────────────────────────────────────────────────────────
  final messageInputController = TextEditingController();
  final searchInputController = TextEditingController();
  final messageFocusNode = FocusNode();
  final chatScrollController = ScrollController();

  bool _isReconnecting = false;
  String _pendingUserText = '';

  @override
  void onInit() {
    super.onInit();
    // Capture pending user text to seed the local session title from the START event.
    messageInputController.addListener(() {
      _pendingUserText = messageInputController.text.trim();
    });
    loadChats();
  }

  @override
  void onClose() {
    _sseSub?.cancel();
    _sseCancel?.cancel();
    messageInputController.dispose();
    searchInputController.dispose();
    messageFocusNode.dispose();
    chatScrollController.dispose();
    super.onClose();
  }

  // ── Conversation list ─────────────────────────────────────────────────────

  /// Fetches the sidebar conversation list using [GET /api/v1/pixo/conversations].
  Future<void> loadChats() async {
    if (isClosed) return;
    isChatsLoading.value = true;
    debugPrint('[Pixo Controller] loadChats starting...');
    try {
      final list = await pixoRepo.getConversations();
      debugPrint('[Pixo Controller] loadChats fetched ${list.length} sessions from repo.');
      for (final s in list) {
        debugPrint('   -> Session ID: "${s.id}" | Title: "${s.title}" | Messages: ${s.messages.length}');
      }
      if (!isClosed) chats.assignAll(list);
    } catch (e) {
      debugPrint('[Pixo Controller Error] loadChats failed: $e');
      if (!isClosed) CM.showToast('Failed to load conversations', isError: true);
    } finally {
      if (!isClosed) isChatsLoading.value = false;
    }
  }

  List<ChatSessionModel> get filteredChats {
    if (searchQuery.value.trim().isEmpty) return chats;
    final q = searchQuery.value.toLowerCase().trim();
    return chats.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  Map<String, List<ChatSessionModel>> get groupedChats {
    final map = <String, List<ChatSessionModel>>{
      'Today': [],
      'Yesterday': [],
      'Previous 7 Days': [],
      'Older': [],
    };
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final prev7 = today.subtract(const Duration(days: 7));

    for (final chat in filteredChats) {
      final d = DateTime(
          chat.updatedAt.year, chat.updatedAt.month, chat.updatedAt.day);
      if (!d.isBefore(today)) {
        map['Today']!.add(chat);
      } else if (d == yesterday) {
        map['Yesterday']!.add(chat);
      } else if (d.isAfter(prev7)) {
        map['Previous 7 Days']!.add(chat);
      } else {
        map['Older']!.add(chat);
      }
    }
    map.removeWhere((_, v) => v.isEmpty);
    return map;
  }

  Future<void> openChat(ChatSessionModel session) async {
    debugPrint('[Pixo Controller] openChat called -> session.id: "${session.id}", title: "${session.title}"');
    _cancelActiveStream(notify: false);
    activeChat.value = session;
    _activeConversationId = int.tryParse(session.id);
    _activeMessageId = null;

    debugPrint('[Pixo Controller] activeConversationId parsed: $_activeConversationId');

    if (session.messages.isNotEmpty) {
      pixoMessages.assignAll(
        session.messages.map(PixoMessage.fromLegacy).toList(),
      );
    } else {
      pixoMessages.clear();
    }
    streamState.value = PixoStreamState.idle;
    _scrollToBottom();

    if (_activeConversationId != null && _activeConversationId! > 0) {
      debugPrint('[Pixo Controller] Fetching history from server for convId: $_activeConversationId');
      final history = await pixoRepo.fetchHistory(_activeConversationId!);
      debugPrint('[Pixo Controller] History returned ${history.length} messages for convId: $_activeConversationId');
      if (history.isNotEmpty && !isClosed) {
        pixoMessages.assignAll(history.map(PixoMessage.fromLegacy).toList());
        _scrollToBottom();
      }
    } else {
      debugPrint('[Pixo Controller Warning] openChat: _activeConversationId is null or <= 0 (session.id was: "${session.id}")');
    }
  }

  void startNewChat() {
    _cancelActiveStream(notify: false);
    activeChat.value = null;
    pixoMessages.clear();
    _activeConversationId = null;
    _activeMessageId = null;
    messageInputController.clear();
    streamState.value = PixoStreamState.idle;
  }

  // ── Send ─────────────────────────────────────────────────────────────────
  //
  // NO pre-flight REST call to create a chat session.
  // The START SSE event establishes the conversationId.

  Future<void> sendMessage([String? prefilledPrompt]) async {
    final text = (prefilledPrompt ?? messageInputController.text).trim();
    if (text.isEmpty || isAiThinkingValue) return;

    debugPrint('[Pixo Controller] Sending message: "$text" | activeConvId: $_activeConversationId');

    messageInputController.clear();
    streamState.value = PixoStreamState.idle;

    // ── User message (local) ──
    final userMsg = PixoMessage(
      localId: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      timestamp: DateTime.now(),
      textContent: text,
    );
    pixoMessages.add(userMsg);
    _scrollToBottom();

    // ── Assistant placeholder (replaced by SSE events) ──
    final placeholderId = 'asst_${DateTime.now().millisecondsSinceEpoch}';
    pixoMessages.add(PixoMessage(
      localId: placeholderId,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isStreaming: true,
      renderMode: PixoRenderMode.streaming,
    ));
    final assistantIndex = pixoMessages.length - 1;

    // ── Open the SSE stream ──
    _sseCancel = CancelToken();
    streamState.value = PixoStreamState.start;

    _sseSub?.cancel();
    _sseSub = pixoRepo
        .stream(
          conversationId: _activeConversationId,
          message: text,
          cancelToken: _sseCancel,
        )
        .listen(
          (event) => _onSseEvent(event, assistantIndex),
          onError: (e) {
            if (!isClosed) {
              _finaliseAssistantMessage(assistantIndex,
                  errorMessage: 'Stream error: $e');
              streamState.value = PixoStreamState.error;
            }
          },
          onDone: () {
            // If the stream closed without COMPLETED → attempt recovery
            if (!isClosed &&
                streamState.value != PixoStreamState.completed &&
                streamState.value != PixoStreamState.cancelled &&
                streamState.value != PixoStreamState.error) {
              _attemptRecovery(assistantIndex);
            }
          },
          cancelOnError: false,
        );
  }

  // ── SSE event dispatcher ──────────────────────────────────────────────────

  void _onSseEvent(PixoEvent event, int assistantIndex) {
    if (isClosed) return;
    debugPrint('[Pixo Controller] Handling event: ${event.runtimeType}');

    switch (event) {
      case PixoStartEvent():
        debugPrint('[Pixo Controller] START -> convId: ${event.conversationId}, msgId: ${event.messageId}');
        if (event.conversationId > 0) {
          _activeConversationId = event.conversationId;
        }
        if (event.messageId > 0) {
          _activeMessageId = event.messageId;
        }
        streamState.value = PixoStreamState.start;

        if (activeChat.value == null) {
          final session = ChatSessionModel(
            id: event.conversationId.toString(),
            title: _pendingUserText,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            messages: [],
          );
          activeChat.value = session;
          chats.insert(0, session);
        }

      case PixoContextReadyEvent():
        debugPrint('[Pixo Controller] CONTEXT_READY');
        streamState.value = PixoStreamState.contextReady;

      case PixoToolResultEvent():
        debugPrint('[Pixo Controller] TOOL_RESULT -> ${event.payload.keys}');
        streamState.value = PixoStreamState.toolResult;
        if (assistantIndex < pixoMessages.length) {
          pixoMessages[assistantIndex] = pixoMessages[assistantIndex].copyWith(
            conversationId: _activeConversationId,
            messageId: _activeMessageId,
            toolResultPayload: event.payload,
            renderMode: PixoRenderMode.toolResult,
          );
        }

      case PixoGeneratingEvent():
        debugPrint('[Pixo Controller] GENERATING tokens...');
        streamState.value = PixoStreamState.generating;

      case PixoTokenEvent():
        if (_activeMessageId != null &&
            event.messageId != _activeMessageId) { return; }
        if (assistantIndex < pixoMessages.length) {
          pixoMessages[assistantIndex] =
              pixoMessages[assistantIndex].appendToken(event.content);
          _scrollToBottom();
        }

      case PixoCompletedEvent():
        debugPrint('[Pixo Controller] COMPLETED turn successfully.');
        streamState.value = PixoStreamState.completed;
        if (assistantIndex < pixoMessages.length) {
          pixoMessages[assistantIndex] =
              pixoMessages[assistantIndex].finalise();
        }
        _sseSub?.cancel();
        _sseCancel = null;
        loadChats();

      case PixoErrorEvent():
        debugPrint('[Pixo Controller Error] Stream error: ${event.message}');
        streamState.value = PixoStreamState.error;
        _finaliseAssistantMessage(assistantIndex, errorMessage: event.message);

      case PixoEntitlementDeniedEvent():
        debugPrint('[Pixo Controller Error] ENTITLEMENT_DENIED -> plan: ${event.requiredPlan}');
        streamState.value = PixoStreamState.entitlementDenied;
        entitlementMessage.value = event.message;
        requiredPlan.value = event.requiredPlan;
        _removeAssistantPlaceholder(assistantIndex);

      case PixoUsageLimitEvent():
        debugPrint('[Pixo Controller Error] USAGE_LIMIT_REACHED -> ${event.message}');
        streamState.value = PixoStreamState.usageLimitReached;
        CM.showToast(event.message, isError: true);
        _removeAssistantPlaceholder(assistantIndex);

      case PixoProviderUnavailableEvent():
        debugPrint('[Pixo Controller Error] PROVIDER_UNAVAILABLE');
        streamState.value = PixoStreamState.providerUnavailable;
        _finaliseAssistantMessage(assistantIndex,
            errorMessage:
                'AI provider is temporarily unavailable. Please try again shortly.');

      case PixoContextUnavailableEvent():
        debugPrint('[Pixo Controller Error] CONTEXT_UNAVAILABLE');
        streamState.value = PixoStreamState.contextUnavailable;
        _finaliseAssistantMessage(assistantIndex, errorMessage: event.message);

      case PixoCancelledEvent():
        debugPrint('[Pixo Controller] Stream CANCELLED');
        streamState.value = PixoStreamState.cancelled;
        _removeAssistantPlaceholder(assistantIndex);

      case PixoUnknownEvent():
        debugPrint('[Pixo Controller] Unknown event: ${event.eventType}');
        break;
    }
  }


  // ── Cancellation — Option B ───────────────────────────────────────────────

  /// Stops generation by invoking the server-side cancel endpoint FIRST, then
  /// dropping the local SSE subscription.
  ///
  /// This prevents orphaned LLM calls on the Java side (M10 acceptance criterion).
  Future<void> stopGenerating() async {
    if (!isAiThinkingValue) return;
    final convId = _activeConversationId;
    final msgId = _activeMessageId;

    _cancelActiveStream(notify: true);

    if (convId != null && msgId != null) {
      await pixoRepo.cancelMessage(
          conversationId: convId, messageId: msgId);
    }
  }

  void _cancelActiveStream({required bool notify}) {
    _sseSub?.cancel();
    _sseSub = null;
    _sseCancel?.cancel('User stopped generation');
    _sseCancel = null;
    if (!isClosed) {
      streamState.value = PixoStreamState.idle;
      if (notify) CM.showToast('Generation stopped.');
    }
  }

  // ── Network Disconnect & Recovery ─────────────────────────────────────────

  /// Called when SSE closes unexpectedly mid-generation.
  ///
  /// Fetches authoritative server state via REST and reconciles using `messageId`.
  /// Never re-sends the original stream request.
  Future<void> _attemptRecovery(int assistantIndex) async {
    if (isClosed || _isReconnecting) return;
    final convId = _activeConversationId;
    if (convId == null) {
      _finaliseAssistantMessage(assistantIndex,
          errorMessage: 'Connection lost. Please retry.');
      streamState.value = PixoStreamState.error;
      return;
    }

    _isReconnecting = true;
    streamState.value = PixoStreamState.reconnecting;

    try {
      final history = await pixoRepo.fetchHistory(convId);
      if (isClosed) return;

      // Find the server's authoritative version of the in-flight assistant message.
      final serverMsg = history.lastWhereOrNull(
        (m) => m.id == _activeMessageId?.toString() ||
            (m.isAssistant &&
                assistantIndex < pixoMessages.length &&
                m.createdAt
                    .isAfter(pixoMessages[assistantIndex].timestamp)),
      );

      if (serverMsg != null && assistantIndex < pixoMessages.length) {
        // Server finished while disconnected — replace local streaming state.
        pixoMessages[assistantIndex] = PixoMessage(
          localId: pixoMessages[assistantIndex].localId,
          conversationId: _activeConversationId,
          messageId: _activeMessageId,
          role: MessageRole.assistant,
          timestamp: serverMsg.createdAt,
          textContent: serverMsg.content,
          isStreaming: false,
          renderMode: PixoRenderMode.text,
        );
        streamState.value = PixoStreamState.completed;
        CM.showToast('Reconnected — conversation restored.');
      } else {
        _finaliseAssistantMessage(assistantIndex,
            errorMessage:
                'Connection lost mid-stream. Pull down to retry.');
        streamState.value = PixoStreamState.error;
      }
    } catch (e) {
      if (!isClosed) {
        _finaliseAssistantMessage(assistantIndex,
            errorMessage: 'Could not restore conversation. Please retry.');
        streamState.value = PixoStreamState.error;
      }
    } finally {
      _isReconnecting = false;
    }
  }

  // ── App backgrounding (M10 acceptance criterion) ──────────────────────────

  /// Called by [WidgetsBindingObserver] when the app returns to foreground.
  Future<void> onAppResumed() async {
    final convId = _activeConversationId;
    if (convId == null || isClosed) return;
    if (isAiThinkingValue) {
      final lastAssistantIdx =
          pixoMessages.lastIndexWhere((m) => m.isAssistant);
      if (lastAssistantIdx != -1) {
        await _attemptRecovery(lastAssistantIdx);
      }
    }
  }

  // ── Regenerate ────────────────────────────────────────────────────────────

  Future<void> regenerateLastMessage() async {
    if (isClosed || pixoMessages.isEmpty || isAiThinkingValue) return;
    final lastUser = pixoMessages.lastWhereOrNull((m) => m.isUser);
    if (lastUser == null) return;
    if (pixoMessages.last.isAssistant) pixoMessages.removeLast();
    await sendMessage(lastUser.textContent);
  }

  // ── Feedback ──────────────────────────────────────────────────────────────

  void toggleLikeMessage(PixoMessage message, bool isLiked) {
    if (isClosed) return;
    final idx = pixoMessages.indexWhere((m) => m.localId == message.localId);
    if (idx != -1) {
      final current = pixoMessages[idx];
      final newLike = current.isLiked == isLiked ? null : isLiked;
      pixoMessages[idx] = current.copyWith(isLiked: newLike);
      CM.showToast(
          newLike == true ? 'Feedback: Liked' : 'Feedback: Disliked');
    }
  }

  void copyMessageContent(String content) {
    Clipboard.setData(ClipboardData(text: content));
    CM.showToast('Copied to clipboard!');
  }

  // ── Session management ────────────────────────────────────────────────────

  Future<void> renameSession(ChatSessionModel session, String newTitle) async {
    if (newTitle.trim().isEmpty || isClosed) return;
    final convId = int.tryParse(session.id);
    if (convId == null) return;

    final ok = await pixoRepo.renameConversation(
        conversationId: convId, newTitle: newTitle.trim());
    if (isClosed) return;
    if (ok) {
      if (activeChat.value?.id == session.id) {
        activeChat.value = activeChat.value!.copyWith(title: newTitle.trim());
      }
      await loadChats();
      CM.showToast('Conversation renamed');
    }
  }

  Future<void> deleteSession(ChatSessionModel session) async {
    if (isClosed) return;
    final convId = int.tryParse(session.id);
    if (convId == null) return;

    final ok = await pixoRepo.deleteConversation(convId);
    if (isClosed) return;
    if (ok) {
      chats.removeWhere((c) => c.id == session.id);
      if (activeChat.value?.id == session.id) startNewChat();
      CM.showToast('Conversation deleted');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _finaliseAssistantMessage(int index, {String? errorMessage}) {
    if (index >= 0 && index < pixoMessages.length) {
      final existing = pixoMessages[index];
      final formattedText = _formatErrorMessage(errorMessage) ??
          (existing.textContent.trim().isNotEmpty
              ? existing.textContent
              : "I'm having trouble processing that right now. Please try again in a moment.");
      pixoMessages[index] = existing.copyWith(
        isStreaming: false,
        renderMode: PixoRenderMode.text,
        hasError: false,
        errorMessage: null,
        textContent: formattedText,
      );
    }
  }

  String? _formatErrorMessage(String? rawError) {
    if (rawError == null || rawError.trim().isEmpty) return null;
    final trimmed = rawError.trim();
    final lower = trimmed.toLowerCase();

    // 1. HTTP and Auth codes
    if (lower.contains('401') || lower.contains('unauthorized')) {
      return "Your session has expired. Please sign in again to continue.";
    }
    if (lower.contains('403') || lower.contains('forbidden')) {
      return "Access denied. A subscription upgrade may be required.";
    }
    if (lower.contains('404') || lower.contains('not found')) {
      return "The requested conversation or resource could not be found.";
    }
    if (lower.contains('429') || lower.contains('too many requests')) {
      return "You've sent too many requests. Please wait a moment and try again.";
    }
    if (lower.contains('500') ||
        lower.contains('502') ||
        lower.contains('503') ||
        lower.contains('504') ||
        lower.contains('server error')) {
      return "The server is temporarily experiencing issues. Please try again shortly.";
    }

    // 2. Network errors
    if (lower.contains('socketexception') ||
        lower.contains('connection refused') ||
        lower.contains('network error') ||
        lower.contains('timeout')) {
      return "Connection error. Please check your internet connection and try again.";
    }

    // 3. Known backend status strings
    if (trimmed == 'ENTITY_RESOLUTION_FAILURE' ||
        trimmed.contains('ENTITY_RESOLUTION_FAILURE')) {
      return "I couldn't resolve or identify the channel or entity you mentioned. Please double-check the channel name or link and try again.";
    }
    if (trimmed == 'ENTITY_NOT_FOUND' || trimmed.contains('ENTITY_NOT_FOUND')) {
      return "I couldn't find the requested channel or video details. Please ensure the information is correct and try again.";
    }
    if (trimmed == 'CONTEXT_UNAVAILABLE' ||
        trimmed.contains('CONTEXT_UNAVAILABLE')) {
      return "Context data for this request is currently unavailable. Please rephrase or try again.";
    }
    if (trimmed == 'PROVIDER_UNAVAILABLE' ||
        trimmed.contains('PROVIDER_UNAVAILABLE')) {
      return "The AI engine is temporarily busy. Please try again shortly.";
    }
    if (trimmed == 'USAGE_LIMIT_REACHED' ||
        trimmed.contains('USAGE_LIMIT_REACHED')) {
      return "You have reached your daily limit for this feature. Please upgrade to Pro to unlock unlimited requests.";
    }
    if (trimmed == 'ENTITLEMENT_DENIED' ||
        trimmed.contains('ENTITLEMENT_DENIED')) {
      return "This feature is available on our Pro plan. Please upgrade your subscription to unlock it.";
    }

    // 4. Any other ALL_CAPS codes
    if (RegExp(r'^[A-Z0-9_]+$').hasMatch(trimmed)) {
      final readable = trimmed.toLowerCase().replaceAll('_', ' ');
      return "Unable to complete request ($readable). Please try again.";
    }

    // 5. Clean any "HTTP xxx" or "Exception: " prefix if present
    if (trimmed.startsWith('HTTP ') ||
        trimmed.startsWith('Exception:') ||
        trimmed.startsWith('Stream error:')) {
      return "Something went wrong while connecting. Please try again in a moment.";
    }

    return trimmed;
  }

  void _removeAssistantPlaceholder(int index) {
    if (index >= 0 && index < pixoMessages.length) {
      final msg = pixoMessages[index];
      if (msg.textContent.isEmpty && msg.toolResultPayload == null) {
        pixoMessages.removeAt(index);
      } else {
        pixoMessages[index] = msg.finalise();
      }
    }
    streamState.value = PixoStreamState.idle;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed && chatScrollController.hasClients) {
        chatScrollController.animateTo(
          chatScrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return DateFormat('hh:mm a').format(dt);
    }
    return DateFormat('MMM dd, hh:mm a').format(dt);
  }
}

// ── Local extension ───────────────────────────────────────────────────────────

extension _IterableX<T> on Iterable<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    T? result;
    for (final e in this) {
      if (test(e)) result = e;
    }
    return result;
  }
}
