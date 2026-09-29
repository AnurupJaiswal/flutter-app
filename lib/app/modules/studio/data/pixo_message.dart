import 'package:lala_ai/Models/chat_model.dart';

/// Render mode for an assistant message in the Pixo chat.
enum PixoRenderMode {
  /// Markdown text streamed from TOKEN events.
  text,

  /// Structured tool result rendered as a custom Flutter widget.
  toolResult,

  /// Streaming state — text is still accumulating.
  streaming,
}

/// A Pixo-aware extension of [ChatMessageModel] that carries the additional
/// metadata needed by the SSE state machine (correlation keys, tool payloads,
/// streaming state).
class PixoMessage {
  final String localId;

  /// Backend-assigned identifiers from the START event.  null until received.
  final int? conversationId;
  final int? messageId;

  final MessageRole role;
  final DateTime timestamp;

  // ── Content ──────────────────────────────────────────────────────────────

  /// Accumulated markdown text from TOKEN events.
  final String textContent;

  /// Structured JSON payload from a TOOL_RESULT event.  null for text turns.
  final Map<String, dynamic>? toolResultPayload;

  /// Whether this message is still accumulating tokens.
  final bool isStreaming;

  /// Render mode determines which widget path to follow.
  final PixoRenderMode renderMode;

  /// Optional like/dislike state.
  final bool? isLiked;

  /// Whether an error occurred during generation.
  final bool hasError;
  final String? errorMessage;

  const PixoMessage({
    required this.localId,
    this.conversationId,
    this.messageId,
    required this.role,
    required this.timestamp,
    this.textContent = '',
    this.toolResultPayload,
    this.isStreaming = false,
    this.renderMode = PixoRenderMode.text,
    this.isLiked,
    this.hasError = false,
    this.errorMessage,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get hasToolResult => toolResultPayload != null;

  PixoMessage copyWith({
    int? conversationId,
    int? messageId,
    String? textContent,
    Map<String, dynamic>? toolResultPayload,
    bool? isStreaming,
    PixoRenderMode? renderMode,
    bool? isLiked,
    bool? hasError,
    String? errorMessage,
  }) {
    return PixoMessage(
      localId: localId,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      role: role,
      timestamp: timestamp,
      textContent: textContent ?? this.textContent,
      toolResultPayload: toolResultPayload ?? this.toolResultPayload,
      isStreaming: isStreaming ?? this.isStreaming,
      renderMode: renderMode ?? this.renderMode,
      isLiked: isLiked ?? this.isLiked,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Append a TOKEN chunk to [textContent] and keep isStreaming=true.
  PixoMessage appendToken(String token) {
    return copyWith(
      textContent: textContent + token,
      isStreaming: true,
      renderMode: hasToolResult ? PixoRenderMode.toolResult : PixoRenderMode.streaming,
    );
  }

  /// Finalise streaming — sets isStreaming=false and locks render mode.
  PixoMessage finalise() {
    return copyWith(
      isStreaming: false,
      renderMode: hasToolResult ? PixoRenderMode.toolResult : PixoRenderMode.text,
    );
  }

  // ── Interop with legacy ChatMessageModel ─────────────────────────────────

  static PixoMessage fromLegacy(ChatMessageModel m) {
    return PixoMessage(
      localId: m.id,
      role: m.role,
      timestamp: m.createdAt,
      textContent: m.content,
      isLiked: m.isLiked,
    );
  }
}
