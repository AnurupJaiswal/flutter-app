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
import 'package:lala_ai/app/modules/studio/data/studio_chat_repository.dart';
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

class StudioController extends GetxController {
  // ── Dependencies ────────────────────────────────────────────────────────
  final StudioChatRepository repository;
  final PixoSseRepository pixoRepo;

  StudioController({
    required this.repository,
    required this.pixoRepo,
  });

  // ── Conversation state ───────────────────────────────────────────────────
  final chats = <ChatSessionModel>[].obs;
  final activeChat = Rxn<ChatSessionModel>();

  /// Pixo-aware message list (replaces the old flat ChatMessageModel list).
  final pixoMessages = <PixoMessage>[].obs;

  final isChatsLoading = false.obs;
  final searchQuery = ''.obs;

  // ── Stream state machine ─────────────────────────────────────────────────
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

  // Reactive bool alias consumed by existing StudioView/Composer widgets.
  RxBool get isAiThinking => isAiThinkingValue.obs;

  // ── SSE correlation keys (from START event) ──────────────────────────────
  int? _activeConversationId;
  int? _activeMessageId;

  // ── Entitlement event data (for modal) ───────────────────────────────────
  final entitlementMessage = ''.obs;
  final requiredPlan = Rxn<String>();

  // ── Cancellation ────────────────────────────────────────────────────────
  CancelToken? _sseCancel;
  StreamSubscription<PixoEvent>? _sseSub;

  // ── UI controllers ───────────────────────────────────────────────────────
  final messageInputController = TextEditingController();
  final searchInputController = TextEditingController();
  final messageFocusNode = FocusNode();
  final chatScrollController = ScrollController();

  // ── Reconnect/app-background tracking ───────────────────────────────────
  bool _isReconnecting = false;

  @override
  void onInit() {
    super.onInit();
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

  // ── Chat list ─────────────────────────────────────────────────────────────

  Future<void> loadChats() async {
    if (isClosed) return;
    isChatsLoading.value = true;
    try {
      final list = await repository.getChats();
      if (!isClosed) chats.assignAll(list);
    } catch (_) {
      if (!isClosed) CM.showToast('Failed to load chat history', isError: true);
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

  void openChat(ChatSessionModel session) {
    activeChat.value = session;
    // Convert legacy messages to PixoMessages
    pixoMessages.assignAll(
      session.messages.map(PixoMessage.fromLegacy).toList(),
    );
    _scrollToBottom();
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

  // ── Send ──────────────────────────────────────────────────────────────────

  Future<void> sendMessage([String? prefilledPrompt]) async {
    final text = (prefilledPrompt ?? messageInputController.text).trim();
    if (text.isEmpty || isAiThinkingValue) return;

    messageInputController.clear();
    streamState.value = PixoStreamState.idle;

    // Create a local chat session if there is none yet.
    if (activeChat.value == null) {
      try {
        final newChat = await repository.createChat(initialMessage: text);
        if (isClosed) return;
        activeChat.value = newChat;
        chats.insert(0, newChat);
      } catch (_) {
        final fb = ChatSessionModel(
          id: 'pixo_${DateTime.now().millisecondsSinceEpoch}',
          title: text.length > 28 ? '${text.substring(0, 28)}...' : text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: [],
        );
        activeChat.value = fb;
        chats.insert(0, fb);
      }
    }

    // Add user message locally.
    final userMsg = PixoMessage(
      localId: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      timestamp: DateTime.now(),
      textContent: text,
    );
    pixoMessages.add(userMsg);
    _scrollToBottom();

    // Add placeholder for assistant response.
    final assistantPlaceholder = PixoMessage(
      localId: 'asst_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isStreaming: true,
      renderMode: PixoRenderMode.streaming,
    );
    pixoMessages.add(assistantPlaceholder);
    final assistantIndex = pixoMessages.length - 1;

    // Open the SSE stream.
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
              _finaliseAssistantMessage(
                assistantIndex,
                errorMessage: 'Stream error: $e',
              );
              streamState.value = PixoStreamState.error;
            }
          },
          onDone: () {
            // If the stream closed without COMPLETED (e.g. network drop),
            // attempt recovery.
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

    switch (event) {
      case PixoStartEvent():
        _activeConversationId = event.conversationId;
        _activeMessageId = event.messageId;
        streamState.value = PixoStreamState.start;

      case PixoContextReadyEvent():
        streamState.value = PixoStreamState.contextReady;

      case PixoToolResultEvent():
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
        streamState.value = PixoStreamState.generating;

      case PixoTokenEvent():
        // Deduplication: only append tokens whose messageId matches.
        if (_activeMessageId != null &&
            event.messageId != _activeMessageId) return;
        if (assistantIndex < pixoMessages.length) {
          pixoMessages[assistantIndex] =
              pixoMessages[assistantIndex].appendToken(event.content);
          _scrollToBottom();
        }

      case PixoCompletedEvent():
        streamState.value = PixoStreamState.completed;
        if (assistantIndex < pixoMessages.length) {
          pixoMessages[assistantIndex] =
              pixoMessages[assistantIndex].finalise();
        }
        _sseSub?.cancel();
        _sseCancel = null;
        loadChats();

      case PixoErrorEvent():
        streamState.value = PixoStreamState.error;
        _finaliseAssistantMessage(assistantIndex,
            errorMessage: event.message);

      case PixoEntitlementDeniedEvent():
        streamState.value = PixoStreamState.entitlementDenied;
        entitlementMessage.value = event.message;
        requiredPlan.value = event.requiredPlan;
        _removeAssistantPlaceholder(assistantIndex);

      case PixoUsageLimitEvent():
        streamState.value = PixoStreamState.usageLimitReached;
        CM.showToast(event.message, isError: true);
        _removeAssistantPlaceholder(assistantIndex);

      case PixoProviderUnavailableEvent():
        streamState.value = PixoStreamState.providerUnavailable;
        _finaliseAssistantMessage(assistantIndex,
            errorMessage:
                'AI provider is temporarily unavailable. Please try again shortly.');

      case PixoContextUnavailableEvent():
        streamState.value = PixoStreamState.contextUnavailable;
        _finaliseAssistantMessage(assistantIndex,
            errorMessage: event.message);

      case PixoCancelledEvent():
        streamState.value = PixoStreamState.cancelled;
        _removeAssistantPlaceholder(assistantIndex);

      case PixoUnknownEvent():
        // Silently ignore unknown events — forward-compatible.
        break;
    }
  }

  // ── Cancellation (Option B) ───────────────────────────────────────────────

  /// Stops generation by calling the backend cancel endpoint, then drops the
  /// local SSE connection.  This prevents orphaned LLM calls.
  Future<void> stopGenerating() async {
    if (!isAiThinkingValue) return;
    final convId = _activeConversationId;
    final msgId = _activeMessageId;

    _cancelActiveStream(notify: true);

    // Option B: tell the backend to halt server-side LLM consumption.
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

  /// Called when the SSE stream closes unexpectedly mid-generation.
  /// Fetches the authoritative server state and reconciles without re-sending
  /// the original user message.
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

      // Find the server's authoritative version of our in-flight message.
      final serverMsg = history.lastWhereOrNull(
        (m) =>
            m.id == _activeMessageId?.toString() ||
            (m.isAssistant && m.createdAt.isAfter(pixoMessages.first.timestamp)),
      );

      if (serverMsg != null && assistantIndex < pixoMessages.length) {
        // Server finished generation while we were disconnected — replace local.
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
        // Server hasn't finished — surface an error with retry option.
        _finaliseAssistantMessage(assistantIndex,
            errorMessage: 'Connection lost mid-stream. Pull down to retry.');
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

  // ── App backgrounding ─────────────────────────────────────────────────────

  /// Called by [WidgetsBindingObserver] in the view when the app returns to
  /// foreground.  If a conversation was in-flight, restores state from the server.
  Future<void> onAppResumed() async {
    final convId = _activeConversationId;
    if (convId == null || isClosed) return;

    // If still showing "thinking", attempt recovery.
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
    final lastUser =
        pixoMessages.lastWhereOrNull((m) => m.isUser);
    if (lastUser == null) return;
    if (pixoMessages.last.isAssistant) pixoMessages.removeLast();
    await sendMessage(lastUser.textContent);
  }

  // ── Like/Dislike ──────────────────────────────────────────────────────────

  void toggleLikeMessage(PixoMessage message, bool isLiked) {
    if (isClosed) return;
    final idx = pixoMessages.indexWhere((m) => m.localId == message.localId);
    if (idx != -1) {
      final current = pixoMessages[idx];
      final newLike = current.isLiked == isLiked ? null : isLiked;
      pixoMessages[idx] = current.copyWith(isLiked: newLike);
      CM.showToast(newLike == true
          ? 'Feedback submitted: Liked'
          : 'Feedback submitted: Disliked');
    }
  }

  void copyMessageContent(String content) {
    Clipboard.setData(ClipboardData(text: content));
    CM.showToast('Copied to clipboard!');
  }

  // ── Session management ────────────────────────────────────────────────────

  Future<void> renameSession(ChatSessionModel session, String newTitle) async {
    if (newTitle.trim().isEmpty || isClosed) return;
    final ok = await repository.renameChat(
        chatId: session.id, newTitle: newTitle.trim());
    if (isClosed) return;
    if (ok) {
      if (activeChat.value?.id == session.id) {
        activeChat.value = activeChat.value!.copyWith(title: newTitle.trim());
      }
      await loadChats();
      CM.showToast('Chat renamed successfully');
    }
  }

  Future<void> deleteSession(ChatSessionModel session) async {
    if (isClosed) return;
    final ok = await repository.deleteChat(session.id);
    if (isClosed) return;
    if (ok) {
      chats.removeWhere((c) => c.id == session.id);
      if (activeChat.value?.id == session.id) startNewChat();
      CM.showToast('Chat deleted');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _finaliseAssistantMessage(int index, {String? errorMessage}) {
    if (index >= 0 && index < pixoMessages.length) {
      final existing = pixoMessages[index];
      final fallback = existing.textContent.trim().isNotEmpty
          ? existing.textContent
          : "Sorry, I couldn't complete that request. Please check your connection and try again.";
      pixoMessages[index] = existing.copyWith(
        isStreaming: false,
        renderMode: PixoRenderMode.text,
        hasError: errorMessage != null,
        errorMessage: errorMessage,
        textContent: errorMessage ?? fallback,
      );
    }
  }

  void _removeAssistantPlaceholder(int index) {
    if (index >= 0 && index < pixoMessages.length) {
      final msg = pixoMessages[index];
      // Only remove if it has no content yet.
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
