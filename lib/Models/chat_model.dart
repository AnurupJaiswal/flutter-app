enum MessageRole {
  user,
  assistant,
  system;

  String toJson() => name;
  static MessageRole fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
      case 'ai':
        return MessageRole.assistant;
      case 'system':
      default:
        return MessageRole.system;
    }
  }
}

enum MessageStatus {
  sending,
  sent,
  failed,
  loading,
  error;

  String toJson() => name;
  static MessageStatus fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'sending':
        return MessageStatus.sending;
      case 'failed':
      case 'error':
        return MessageStatus.error;
      case 'loading':
        return MessageStatus.loading;
      case 'sent':
      default:
        return MessageStatus.sent;
    }
  }
}

class AiCodeSnippetModel {
  final String language;
  final String code;
  final String? explanation;

  AiCodeSnippetModel({
    this.language = "DART",
    required this.code,
    this.explanation,
  });

  factory AiCodeSnippetModel.fromJson(Map<String, dynamic> json) {
    return AiCodeSnippetModel(
      language: json['language']?.toString().toUpperCase() ?? "DART",
      code: json['code']?.toString() ?? json['snippet']?.toString() ?? "",
      explanation: json['explanation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'code': code,
      'explanation': explanation,
    };
  }
}

class ChatMessageModel {
  final String id;
  final String chatId;
  final String content;
  final MessageRole role;
  final DateTime createdAt;
  MessageStatus status;
  final List<AiCodeSnippetModel> codeSnippets;
  final List<String> suggestedPrompts;
  bool? isLiked;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.content,
    required this.role,
    DateTime? createdAt,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
    this.codeSnippets = const [],
    this.suggestedPrompts = const [],
    this.isLiked,
  }) : createdAt = createdAt ?? timestamp ?? DateTime.now();

  DateTime get timestamp => createdAt;
  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  ChatMessageModel copyWith({
    String? id,
    String? chatId,
    String? content,
    MessageRole? role,
    DateTime? createdAt,
    MessageStatus? status,
    List<AiCodeSnippetModel>? codeSnippets,
    List<String>? suggestedPrompts,
    bool? isLiked,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      codeSnippets: codeSnippets ?? this.codeSnippets,
      suggestedPrompts: suggestedPrompts ?? this.suggestedPrompts,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    List<AiCodeSnippetModel> snippets = [];
    final dynamic rawSnippets = json['codeSnippets'] ?? json['snippets'];
    if (rawSnippets is List) {
      snippets = rawSnippets.map((e) {
        if (e is Map<String, dynamic>) {
          return AiCodeSnippetModel.fromJson(e);
        } else {
          return AiCodeSnippetModel(code: e.toString());
        }
      }).toList();
    }

    List<String> parseList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ChatMessageModel(
      id: json['id']?.toString() ?? json['uuid']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: json['chatId']?.toString() ?? "",
      content: json['content']?.toString() ?? json['message']?.toString() ?? "",
      role: MessageRole.fromJson(json['role']?.toString() ?? (json['isUser'] == true ? 'user' : 'assistant')),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['timestamp'] != null ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now() : DateTime.now()),
      status: MessageStatus.fromJson(json['status']?.toString() ?? 'sent'),
      codeSnippets: snippets,
      suggestedPrompts: parseList(json['suggestedPrompts'] ?? json['followUps']),
      isLiked: json['isLiked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'content': content,
      'role': role.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.toJson(),
      'codeSnippets': codeSnippets.map((e) => e.toJson()).toList(),
      'suggestedPrompts': suggestedPrompts,
      'isLiked': isLiked,
    };
  }
}

class ChatSessionModel {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<ChatMessageModel> messages;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  ChatSessionModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessageModel>? messages,
  }) {
    return ChatSessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  String get lastMessagePreview {
    if (messages.isEmpty) return "No messages yet";
    return messages.last.content;
  }

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    final List<ChatMessageModel> parsedMessages = [];
    if (json['messages'] is List) {
      for (final item in json['messages']) {
        if (item is Map<String, dynamic>) {
          parsedMessages.add(ChatMessageModel.fromJson(item));
        }
      }
    }

    return ChatSessionModel(
      id: json['id']?.toString() ?? json['uuid']?.toString() ?? "",
      title: json['title']?.toString() ?? "New Chat",
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      messages: parsedMessages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}
