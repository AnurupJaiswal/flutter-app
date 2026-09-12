import 'package:lala_ai/Models/chat_model.dart';

abstract class ChatRepository {
  Future<List<ChatSessionModel>> getChats();
  Future<ChatSessionModel?> getChat(String chatId);
  Future<ChatSessionModel> createChat({String? title, String? initialMessage});
  Future<ChatMessageModel> sendMessage({required String chatId, required String message});
  Future<bool> deleteChat(String chatId);
  Future<bool> renameChat({required String chatId, required String newTitle});
}

/// Development & Mock Repository with realistic ChatGPT AI responses
class MockChatRepository implements ChatRepository {
  final List<ChatSessionModel> _sessions = [];

  MockChatRepository() {
    _seedInitialConversations();
  }

  @override
  Future<List<ChatSessionModel>> getChats() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_sessions);
  }

  @override
  Future<ChatSessionModel?> getChat(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _sessions.firstWhereOrNull((s) => s.id == chatId);
  }

  @override
  Future<ChatSessionModel> createChat({String? title, String? initialMessage}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final autoTitle = title ??
        (initialMessage != null && initialMessage.length > 30
            ? "${initialMessage.substring(0, 30)}..."
            : initialMessage ?? "New Chat");

    final newSession = ChatSessionModel(
      id: "session_${DateTime.now().millisecondsSinceEpoch}",
      title: autoTitle,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );

    _sessions.insert(0, newSession);
    return newSession;
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String message,
  }) async {
    // Realistic AI thinking delay
    await Future.delayed(const Duration(milliseconds: 1100));

    final session = _sessions.firstWhereOrNull((s) => s.id == chatId);
    final userMsg = ChatMessageModel(
      id: "msg_user_${DateTime.now().millisecondsSinceEpoch}",
      chatId: chatId,
      role: MessageRole.user,
      content: message,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    session?.messages.add(userMsg);

    // Context-aware AI response generation
    final aiResponse = _generateAiResponse(chatId, message);
    session?.messages.add(aiResponse);
    session?.updatedAt = DateTime.now();

    return aiResponse;
  }

  @override
  Future<bool> deleteChat(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _sessions.removeWhere((s) => s.id == chatId);
    return true;
  }

  @override
  Future<bool> renameChat({required String chatId, required String newTitle}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _sessions.indexWhere((s) => s.id == chatId);
    if (index != -1) {
      final old = _sessions[index];
      _sessions[index] = ChatSessionModel(
        id: old.id,
        title: newTitle,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        messages: old.messages,
      );
      return true;
    }
    return false;
  }

  ChatMessageModel _generateAiResponse(String chatId, String prompt) {
    final lower = prompt.toLowerCase();
    String content;
    List<AiCodeSnippetModel> snippets = [];
    List<String> suggestions = [];

    final isHindi = RegExp(r'[\u0900-\u097F]').hasMatch(prompt) ||
        lower.contains("kya") ||
        lower.contains("kaise") ||
        lower.contains("batao") ||
        lower.contains("karo");
    final isSpanish = lower.contains("como") ||
        lower.contains("hola") ||
        lower.contains("gracias") ||
        lower.contains("por favor");

    if (isHindi) {
      content =
          "आपके वॉइस / टेक्स्ट प्रॉम्प्ट का विश्लेषण (**\"$prompt\"**):\n\n1. **हुक और शुरुआत (Hook)**: दर्शकों का ध्यान खींचने के लिए एक सवाल या चौंकाने वाले तथ्य से शुरुआत करें।\n2. **तेज गति (Fast Pacing)**: हर 2.5 सेकंड में विजुअल कट या स्क्रीन टेक्स्ट बदलें।\n3. **कॉल टू एक्शन (CTA)**: अंत में दर्शकों को सब्सक्राइब या फॉलो करने के लिए कहें।";
      snippets.add(
        AiCodeSnippetModel(
          language: "markdown",
          code: """[शॉर्ट्स स्क्रिप्ट ड्राफ्ट]
विषय: $prompt
फॉर्मेट: यूट्यूब शॉर्ट्स / इंस्टाग्राम रील्स
लक्ष्य: व्यूज और सब्सक्राइबर में वृद्धि""",
        ),
      );
      suggestions = [
        "5 और वायरल हुक आइडिया बताओ",
        "इस हुक के लिए 60-सेकंड की हिंदी स्क्रिप्ट लिखो",
        "मेरे चैनल के लिए बेस्ट अपलोड टाइम क्या है?",
      ];
    } else if (isSpanish) {
      content =
          "Analicé tu solicitud: **\"$prompt\"**.\n\nAquí está la recomendación de estrategia de contenido:\n1. **Gancho (Hook)**: Comienza con una pregunta impactante en los primeros 3 segundos.\n2. **Ritmo Rápido**: Cambia de toma o agrega texto cada 2.5 segundos.\n3. **Llamado a la Acción**: Invita a seguir la cuenta al final.";
      snippets.add(
        AiCodeSnippetModel(
          language: "markdown",
          code: """[BORRADOR DE GUION]
Tema: $prompt
Formato: YouTube Short / Instagram Reel
Objetivo: Crecimiento de audiencia""",
        ),
      );
      suggestions = [
        "Dame 5 plantillas de ganchos virales",
        "Escribe un guion completo de 60 segundos",
        "Optimiza el título para SEO",
      ];
    } else if (lower.contains("hook") || lower.contains("retention") || lower.contains("short") || lower.contains("reel")) {
      content =
          "To maximize retention and stop users from scrolling past your short-form video in the first 3 seconds, follow this high-converting hook formula:\n\n1. **Pattern Interrupt**: Start with a visual movement or sudden action.\n2. **Curiosity Gap**: State a compelling problem or surprising stat.\n3. **Fast Pacing**: Cut or zoom every 2.5 seconds.";
      snippets.add(
        AiCodeSnippetModel(
          language: "markdown",
          code: """[0-3s HOOK] "90% of creators make this fatal thumbnail mistake... here is how to fix it in 10 seconds."
[3-15s BODY] Show screen recording of high-contrast overlay vs low-contrast overlay.
[15-30s PAYOFF] Reveal the exact color palette rule (+24% CTR increase).
[30s CTA] "Tap follow for daily AI video growth tips." """,
        ),
      );
      suggestions = [
        "Give me 5 more hook templates for YouTube Shorts",
        "How do I fix drop-off at the 45-second mark?",
        "Write a 60-second Reels script for this hook",
      ];
    } else if (lower.contains("title") || lower.contains("seo") || lower.contains("desc") || lower.contains("keyword")) {
      content =
          "Here are 3 high-CTR YouTube title options optimized for high search volume and click intent, along with a keyword-rich video description format:";
      snippets.add(
        AiCodeSnippetModel(
          language: "markdown",
          code: """Title Options:
1. I Tried 50 AI Video Tools: Only These 3 Are Worth It
2. Stop Making YouTube Shorts Like This (Do This Instead)
3. How I Script 30 Reels in 1 Hour with Lala AI

SEO Tags / Keywords:
#CreatorEconomy #YouTubeGrowth #ContentStrategy #Reels2026 #AITools""",
        ),
      );
      suggestions = [
        "Write an Instagram Reels caption for this topic",
        "Suggest a thumbnail text overlay",
        "Generate 10 trending hashtags",
      ];
    } else if (lower.contains("audit") || lower.contains("growth") || lower.contains("schedule") || lower.contains("upload")) {
      content =
          "Based on your Lala AI Channel Audit analysis:\n\n* **Optimal Post Window**: Friday between 5:00 PM - 7:00 PM local time (82% active subscriber base).\n* **Upload Frequency**: 1–2 Shorts daily + 3 Reels weekly for steady return audience growth.\n* **Health Score Strategy**: Increasing video description SEO tags will boost discovery by up to +18%.";
      suggestions.addAll([
        "Show my SWOT Channel Audit breakdown",
        "Help me plan next week's content calendar",
        "How to boost channel engagement rate",
      ]);
    } else {
      content =
          "I analyzed your request: **\"$prompt\"**.\n\nHere is your creator strategy recommendation:\n1. **Hook & Intro**: Lead with a high-stakes question to lock viewer attention.\n2. **Visual Pacing**: Pair audio with rapid screen overlays or captions.\n3. **Call-to-Action**: End with a specific, frictionless prompt for subscribers.\n\nWould you like me to generate a full script or content breakdown for this?";
      snippets.add(
        AiCodeSnippetModel(
          language: "markdown",
          code: """[SCRIPT DRAFT]
Topic: $prompt
Format: YouTube Short / Instagram Reel
Pacing: Fast (140-160 WPM)
Goal: Subscriber Growth & Higher CTR""",
        ),
      );
      suggestions = [
        "Write a full 60-second video script",
        "Generate 3 thumbnail text ideas",
        "Push this to my Content Calendar",
      ];
    }

    return ChatMessageModel(
      id: "msg_ai_${DateTime.now().millisecondsSinceEpoch}",
      chatId: chatId,
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      codeSnippets: snippets,
      suggestedPrompts: suggestions,
    );
  }

  void _seedInitialConversations() {
    final now = DateTime.now();

    // 1. Today
    _sessions.add(
      ChatSessionModel(
        id: "session_today_1",
        title: "Shorts Retention Strategy",
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        messages: [
          ChatMessageModel(
            id: "m1",
            chatId: "session_today_1",
            role: MessageRole.user,
            content: "How can I boost my Short-form video retention past 75%?",
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
          ChatMessageModel(
            id: "m2",
            chatId: "session_today_1",
            role: MessageRole.assistant,
            content:
                "To increase retention on YouTube Shorts & Reels above 75%:\n\n1. **The 3-Second Hook**: Start immediately with a high-curiosity question or action.\n2. **Pacing & Micro-cuts**: Change visual angle or text on screen every 2.5 seconds.\n3. **Pattern Interrupts**: Use subtle sound effects or visual zoom-ins.\n4. **Open Loop**: Tease the final reveal at the start to keep viewers until the end.",
            timestamp: now.subtract(const Duration(hours: 2)),
            codeSnippets: [
              AiCodeSnippetModel(
                language: "markdown",
                code: """[HOOK EXAMPLE]
"Stop using default thumbnails! Here is how 1 simple tweak boosted my CTR by 24% in 48 hours." """,
              ),
            ],
          ),
        ],
      ),
    );

    // 2. Yesterday
    _sessions.add(
      ChatSessionModel(
        id: "session_yesterday_1",
        title: "High-CTR Video Titles",
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 2)),
        messages: [
          ChatMessageModel(
            id: "m3",
            chatId: "session_yesterday_1",
            role: MessageRole.user,
            content: "Give me 3 high-CTR titles for a tech video.",
            timestamp: now.subtract(const Duration(days: 1, hours: 3)),
          ),
          ChatMessageModel(
            id: "m4",
            chatId: "session_yesterday_1",
            role: MessageRole.assistant,
            content:
                "Here are 3 high-click-through-rate title options:\n\n1. *\"I Tried 50 AI Tools: Only These 3 Are Worth It\"*\n2. *\"How I Script 30 Short Videos in 1 Hour (AI Automation)\"*\n3. *\"Stop Making Shorts Like This (Do This Instead)\"*",
            timestamp: now.subtract(const Duration(days: 1, hours: 3)),
          ),
        ],
      ),
    );

    // 3. Previous 7 Days
    _sessions.add(
      ChatSessionModel(
        id: "session_prev_1",
        title: "Weekly Posting Schedule",
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
        messages: [
          ChatMessageModel(
            id: "m5",
            chatId: "session_prev_1",
            role: MessageRole.user,
            content: "What's the best posting frequency for YouTube Shorts & Reels?",
            timestamp: now.subtract(const Duration(days: 4)),
          ),
          ChatMessageModel(
            id: "m6",
            chatId: "session_prev_1",
            role: MessageRole.assistant,
            content:
                "For optimal audience return rates:\n\n* **YouTube Shorts**: 1–2 posts daily (best window: 12:00 PM & 6:00 PM local time).\n* **Instagram Reels**: 5–7 posts weekly with story polls for engagement.\n* **Consistency**: Maintain fixed days (e.g. Tue/Fri) so your audience builds a viewing habit.",
            timestamp: now.subtract(const Duration(days: 4)),
          ),
        ],
      ),
    );
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
