import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/app/modules/studio/data/studio_chat_repository.dart';
import 'package:lala_ai/utils/common_methods.dart';

class StudioController extends GetxController {
  final StudioChatRepository repository;

  StudioController({required this.repository});

  final chats = <ChatSessionModel>[].obs;
  final activeChat = Rxn<ChatSessionModel>();
  final messages = <ChatMessageModel>[].obs;

  final isChatsLoading = false.obs;
  final isAiThinking = false.obs;
  final searchQuery = ''.obs;

  final messageInputController = TextEditingController();
  final searchInputController = TextEditingController();
  final messageFocusNode = FocusNode();
  final chatScrollController = ScrollController();

  bool _isGeneratingCancelled = false;

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  @override
  void onClose() {
    messageInputController.dispose();
    searchInputController.dispose();
    messageFocusNode.dispose();
    chatScrollController.dispose();
    super.onClose();
  }

  Future<void> loadChats() async {
    if (isClosed) return;
    isChatsLoading.value = true;
    try {
      final list = await repository.getChats();
      if (isClosed) return;
      chats.assignAll(list);
    } catch (e) {
      if (!isClosed) {
        CM.showToast("Failed to load studio chat history", isError: true);
      }
    } finally {
      if (!isClosed) {
        isChatsLoading.value = false;
      }
    }
  }

  /// Filtered list of chats based on search
  List<ChatSessionModel> get filteredChats {
    if (searchQuery.value.trim().isEmpty) return chats;
    final q = searchQuery.value.toLowerCase().trim();
    return chats.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  /// Groups chats chronologically (Today, Yesterday, Previous 7 Days, Older)
  Map<String, List<ChatSessionModel>> get groupedChats {
    final Map<String, List<ChatSessionModel>> map = {
      "Today": [],
      "Yesterday": [],
      "Previous 7 Days": [],
      "Older": [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final prev7Days = today.subtract(const Duration(days: 7));

    for (var chat in filteredChats) {
      final chatDate = DateTime(chat.updatedAt.year, chat.updatedAt.month, chat.updatedAt.day);

      if (chatDate.isAtSameMomentAs(today) || chatDate.isAfter(today)) {
        map["Today"]!.add(chat);
      } else if (chatDate.isAtSameMomentAs(yesterday)) {
        map["Yesterday"]!.add(chat);
      } else if (chatDate.isAfter(prev7Days)) {
        map["Previous 7 Days"]!.add(chat);
      } else {
        map["Older"]!.add(chat);
      }
    }

    map.removeWhere((key, value) => value.isEmpty);
    return map;
  }

  void openChat(ChatSessionModel session) {
    activeChat.value = session;
    messages.assignAll(session.messages);
    _scrollToBottom();
  }

  void startNewChat() {
    activeChat.value = null;
    messages.clear();
    messageInputController.clear();
  }

  Future<void> sendMessage([String? prefilledPrompt]) async {
    final text = (prefilledPrompt ?? messageInputController.text).trim();
    if (text.isEmpty || isAiThinking.value) return;

    messageInputController.clear();
    _isGeneratingCancelled = false;

    // 1. If no active chat session, create one reactively (switches view in-place)
    if (activeChat.value == null) {
      try {
        final newChat = await repository.createChat(initialMessage: text);
        if (isClosed) return;
        activeChat.value = newChat;
        chats.insert(0, newChat);
      } catch (_) {
        if (isClosed) return;
        // Resilient fallback session so content is never lost
        final fallbackChat = ChatSessionModel(
          id: "studio_session_${DateTime.now().millisecondsSinceEpoch}",
          title: text.length > 28 ? "${text.substring(0, 28)}..." : text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: [],
        );
        activeChat.value = fallbackChat;
        chats.insert(0, fallbackChat);
      }
    }

    final currentChatId = activeChat.value?.id ?? "studio_session_${DateTime.now().millisecondsSinceEpoch}";

    // 2. Add User Message locally
    final userMsg = ChatMessageModel(
      id: "studio_usr_${DateTime.now().millisecondsSinceEpoch}",
      chatId: currentChatId,
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    if (isClosed) return;
    messages.add(userMsg);
    _scrollToBottom();

    // 3. Request AI Response
    isAiThinking.value = true;

    try {
      final aiResponse = await repository.sendMessage(
        chatId: currentChatId,
        message: text,
      );

      if (isClosed) return;
      if (!_isGeneratingCancelled) {
        messages.add(aiResponse);
        _scrollToBottom();
      }
    } catch (e) {
      if (isClosed) return;
      if (!_isGeneratingCancelled) {
        messages.add(
          ChatMessageModel(
            id: "studio_err_${DateTime.now().millisecondsSinceEpoch}",
            chatId: currentChatId,
            role: MessageRole.assistant,
            content: "Sorry, I couldn't generate a response. Please check your network connection and try again.",
            timestamp: DateTime.now(),
            status: MessageStatus.error,
          ),
        );
      }
    } finally {
      if (!isClosed) {
        isAiThinking.value = false;
        await loadChats();
      }
    }
  }

  void stopGenerating() {
    _isGeneratingCancelled = true;
    if (!isClosed) {
      isAiThinking.value = false;
      CM.showToast("Generation stopped.");
    }
  }

  Future<void> regenerateLastMessage() async {
    if (isClosed || messages.isEmpty || isAiThinking.value) return;

    final lastUserMsg = messages.where((m) => m.isUser).lastOrNull;
    if (lastUserMsg == null) return;

    if (messages.last.isAssistant) {
      messages.removeLast();
    }

    await sendMessage(lastUserMsg.content);
  }

  void toggleLikeMessage(ChatMessageModel message, bool isLiked) {
    if (isClosed) return;
    final index = messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      final current = messages[index];
      final newLikeState = current.isLiked == isLiked ? null : isLiked;
      messages[index] = current.copyWith(isLiked: newLikeState);
      CM.showToast(newLikeState == true ? "Feedback submitted: Liked" : "Feedback submitted: Disliked");
    }
  }

  void copyMessageContent(String content) {
    Clipboard.setData(ClipboardData(text: content));
    CM.showToast("Copied to clipboard!");
  }

  Future<void> renameSession(ChatSessionModel session, String newTitle) async {
    if (newTitle.trim().isEmpty || isClosed) return;
    final success = await repository.renameChat(
      chatId: session.id,
      newTitle: newTitle.trim(),
    );
    if (isClosed) return;
    if (success) {
      if (activeChat.value?.id == session.id) {
        activeChat.value = activeChat.value!.copyWith(title: newTitle.trim());
      }
      await loadChats();
      CM.showToast("Chat renamed successfully");
    }
  }

  Future<void> deleteSession(ChatSessionModel session) async {
    if (isClosed) return;
    final success = await repository.deleteChat(session.id);
    if (isClosed) return;
    if (success) {
      chats.removeWhere((c) => c.id == session.id);
      if (activeChat.value?.id == session.id) {
        startNewChat();
      }
      CM.showToast("Chat deleted");
    }
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
