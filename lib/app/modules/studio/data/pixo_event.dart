/// Sealed class hierarchy that models the SSE state machine for Pixo.
///
/// Every `event:` line emitted by `POST /api/v1/pixo/stream` maps to
/// exactly one subclass.  Flutter never adds business logic based on
/// token content — it only dispatches on the event type.
sealed class PixoEvent {
  const PixoEvent();

  /// Build the correct subclass from an already-decoded [eventType] string and
  /// [data] map supplied by [PixoSseRepository].
  factory PixoEvent.fromParsed(String eventType, Map<String, dynamic> data) {
    switch (eventType.toUpperCase()) {
      case 'START':
        return PixoStartEvent(
          conversationId: (data['conversationId'] as num?)?.toInt() ?? 0,
          messageId: (data['messageId'] as num?)?.toInt() ?? 0,
        );
      case 'CONTEXT_READY':
        return const PixoContextReadyEvent();
      case 'TOOL_RESULT':
        return PixoToolResultEvent(payload: Map<String, dynamic>.from(data));
      case 'GENERATING':
        return const PixoGeneratingEvent();
      case 'TOKEN':
        return PixoTokenEvent(
          conversationId: (data['conversationId'] as num?)?.toInt() ?? 0,
          messageId: (data['messageId'] as num?)?.toInt() ?? 0,
          content: data['content']?.toString() ?? '',
        );
      case 'COMPLETED':
        return const PixoCompletedEvent();
      case 'ERROR':
        return PixoErrorEvent(
            message: data['message']?.toString() ?? 'Unknown error');
      case 'ENTITLEMENT_DENIED':
        return PixoEntitlementDeniedEvent(
          message: data['message']?.toString() ?? 'Subscription required',
          requiredPlan: data['requiredPlan']?.toString(),
        );
      case 'USAGE_LIMIT_REACHED':
        return PixoUsageLimitEvent(
            message: data['message']?.toString() ?? 'Usage limit reached');
      case 'PROVIDER_UNAVAILABLE':
        return const PixoProviderUnavailableEvent();
      case 'CONTEXT_UNAVAILABLE':
        return PixoContextUnavailableEvent(
          message: data['message']?.toString() ?? 'Entity not found',
        );
      case 'CANCELLED':
        return const PixoCancelledEvent();
      default:
        return PixoUnknownEvent(eventType: eventType);
    }
  }
}

// ── Normal flow states ────────────────────────────────────────────────────────

/// Emitted when the backend accepts the request.
/// Establishes the [conversationId] + [messageId] correlation key.
class PixoStartEvent extends PixoEvent {
  final int conversationId;
  final int messageId;
  const PixoStartEvent(
      {required this.conversationId, required this.messageId});
}

/// Backend has fetched RAG memories / user profiles.
class PixoContextReadyEvent extends PixoEvent {
  const PixoContextReadyEvent();
}

/// Structured JSON data from a capability (audit, trends, compare, etc.).
/// Flutter renders this as a custom Widget — never as markdown text.
class PixoToolResultEvent extends PixoEvent {
  final Map<String, dynamic> payload;
  const PixoToolResultEvent({required this.payload});
}

/// LLM is about to begin streaming conversational text.
class PixoGeneratingEvent extends PixoEvent {
  const PixoGeneratingEvent();
}

/// A markdown text chunk.  Append to the streaming buffer only.
class PixoTokenEvent extends PixoEvent {
  final int conversationId;
  final int messageId;
  final String content;
  const PixoTokenEvent({
    required this.conversationId,
    required this.messageId,
    required this.content,
  });
}

/// The turn is fully finished.  Transition back to IDLE.
class PixoCompletedEvent extends PixoEvent {
  const PixoCompletedEvent();
}

// ── Terminal / Error states ───────────────────────────────────────────────────

class PixoErrorEvent extends PixoEvent {
  final String message;
  const PixoErrorEvent({required this.message});
}

/// User lacks the subscription level required for this command.
/// Show an upsell UI — never hard-code paywall logic in Flutter.
class PixoEntitlementDeniedEvent extends PixoEvent {
  final String message;
  final String? requiredPlan;
  const PixoEntitlementDeniedEvent(
      {required this.message, this.requiredPlan});
}

class PixoUsageLimitEvent extends PixoEvent {
  final String message;
  const PixoUsageLimitEvent({required this.message});
}

class PixoProviderUnavailableEvent extends PixoEvent {
  const PixoProviderUnavailableEvent();
}

class PixoContextUnavailableEvent extends PixoEvent {
  final String message;
  const PixoContextUnavailableEvent({required this.message});
}

class PixoCancelledEvent extends PixoEvent {
  const PixoCancelledEvent();
}

class PixoUnknownEvent extends PixoEvent {
  final String eventType;
  const PixoUnknownEvent({required this.eventType});
}
