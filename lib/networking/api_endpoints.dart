class ApiEndpoints {
  // Base URLs
  // static const String baseUrl =
  //     'https://purple-primarily-coated-happens.trycloudflare.com';

  static const String baseUrl =
      'https://places-strings-guarantee-ways.trycloudflare.com';

  static const String signupUrl =
      'https://lala-ai-green.vercel.app/auth/get-started?redirect=/checkout';

  // --- Auth Endpoints ---
  static const String login = '/api/v1/auth/login';
  static const String requestOtp = '/api/v1/auth/request-otp';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String me = '/api/v1/auth/me';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String completeSetup = '/api/v1/auth/complete-setup';

  // --- Creator & Social Connection Endpoints ---
  static const String creatorConnections = '/api/v1/creators/me/connections';
  static String youtubeAuth([dynamic connectedAccountId]) =>
      connectedAccountId != null
      ? '/api/v1/creators/me/connections/youtube/auth?connectedAccountId=$connectedAccountId'
      : '/api/v1/creators/me/connections/youtube/auth';
  static const String instagramAuth =
      '/api/v1/creators/me/connections/instagram/auth';
  static String deleteConnection(String connectionId) =>
      '/api/v1/creators/me/connections/$connectionId';
  static const String compareCreator = '/api/v1/creators/me/compare';

  // --- Category Endpoints ---
  static const String categories = '/api/v1/categories';
  static const String myCategories = '/api/v1/categories/my';
  static const String subscribeCategory = '/api/v1/categories/subscribe';
  static const String unsubscribeCategory = '/api/v1/categories/unsubscribe';

  // --- Creator Analytics Endpoints ---
  static String analyticsOverview(
    String platform, [
    String period = '30d',
    dynamic connectedAccountId,
  ]) => connectedAccountId != null
      ? '/api/v1/creators/me/analytics/${platform.toLowerCase()}/overview?period=$period&connectedAccountId=$connectedAccountId'
      : '/api/v1/creators/me/analytics/${platform.toLowerCase()}/overview?period=$period';

  static String analyticsGrowth(
    String platform, [
    String period = '30d',
    dynamic connectedAccountId,
  ]) => connectedAccountId != null
      ? '/api/v1/creators/me/analytics/${platform.toLowerCase()}/growth?period=$period&connectedAccountId=$connectedAccountId'
      : '/api/v1/creators/me/analytics/${platform.toLowerCase()}/growth?period=$period';

  static String analyticsEngagement(
    String platform, [
    String period = '30d',
    dynamic connectedAccountId,
  ]) => connectedAccountId != null
      ? '/api/v1/creators/me/analytics/${platform.toLowerCase()}/engagement?period=$period&connectedAccountId=$connectedAccountId'
      : '/api/v1/creators/me/analytics/${platform.toLowerCase()}/engagement?period=$period';

  static String analyticsActivity(
    String platform, [
    String period = '30d',
    dynamic connectedAccountId,
  ]) => connectedAccountId != null
      ? '/api/v1/creators/me/analytics/${platform.toLowerCase()}/activity?period=$period&connectedAccountId=$connectedAccountId'
      : '/api/v1/creators/me/analytics/${platform.toLowerCase()}/activity?period=$period';

  static String analyticsTopContent(
    String platform, [
    String period = '30d',
    int limit = 5,
    dynamic connectedAccountId,
  ]) => connectedAccountId != null
      ? '/api/v1/creators/me/analytics/${platform.toLowerCase()}/top-content?period=$period&limit=$limit&connectedAccountId=$connectedAccountId'
      : '/api/v1/creators/me/analytics/${platform.toLowerCase()}/top-content?period=$period&limit=$limit';

  // Specific Platform Analytics Aliases
  static String youtubeOverview([
    String period = '30d',
    dynamic connectedAccountId,
  ]) => analyticsOverview('youtube', period, connectedAccountId);
  static String youtubeGrowth([
    String period = '30d',
    dynamic connectedAccountId,
  ]) => analyticsGrowth('youtube', period, connectedAccountId);
  static String youtubeEngagement([
    String period = '30d',
    dynamic connectedAccountId,
  ]) => analyticsEngagement('youtube', period, connectedAccountId);
  static String youtubeActivity([
    String period = '30d',
    dynamic connectedAccountId,
  ]) => analyticsActivity('youtube', period, connectedAccountId);
  static String youtubeTopContent([
    String period = '30d',
    int limit = 5,
    dynamic connectedAccountId,
  ]) => analyticsTopContent('youtube', period, limit, connectedAccountId);

  static String instagramOverview([
    String period = '30d',
    dynamic connectedAccountId,
  ]) => analyticsOverview('instagram', period, connectedAccountId);
  static String instagramGrowth([
    String period = '30d',
    dynamic connectedAccountId,
  ]) => analyticsGrowth('instagram', period, connectedAccountId);
  static String instagramEngagement([
    String period = '30d',
    dynamic connectedAccountId,
  ]) => analyticsEngagement('instagram', period, connectedAccountId);
  static String instagramActivity([
    String period = '30d',
    dynamic connectedAccountId,
  ]) => analyticsActivity('instagram', period, connectedAccountId);
  static String instagramTopContent([
    String period = '30d',
    int limit = 5,
    dynamic connectedAccountId,
  ]) => analyticsTopContent('instagram', period, limit, connectedAccountId);

  // Dashboard & Audit Endpoints
  static String dashboardOverview(dynamic connectedAccountId) =>
      connectedAccountId != null
      ? '/api/v1/dashboard/overview?connectedAccountId=$connectedAccountId'
      : '/api/v1/dashboard/overview';

  // Creator To-Dos Endpoints
  static String dashboardTodos([dynamic connectedAccountId]) =>
      connectedAccountId != null
      ? '/api/v1/dashboard/todos?connectedAccountId=$connectedAccountId'
      : '/api/v1/dashboard/todos';
  static const String dashboardTodosConvert = '/api/v1/dashboard/todos/convert';
  static String dashboardTodoUpdate(dynamic todoId) =>
      '/api/v1/dashboard/todos/$todoId';
  static String dashboardTodoDelete(dynamic todoId) =>
      '/api/v1/dashboard/todos/$todoId';

  // Creator Calendar Endpoints
  static const String calendarDrafts = '/api/v1/calendar/drafts';
  static String calendarDraftsList({
    dynamic accountId,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
    String? status,
    String? contentType,
    int? page,
    int? limit,
  }) {
    final queryParams = <String>[];
    if (accountId != null) queryParams.add('accountId=$accountId');
    if (startDate != null) {
      queryParams.add(
        'startDate=${Uri.encodeComponent(startDate.toUtc().toIso8601String())}',
      );
    }
    if (endDate != null) {
      queryParams.add(
        'endDate=${Uri.encodeComponent(endDate.toUtc().toIso8601String())}',
      );
    }
    if (year != null) queryParams.add('year=$year');
    if (month != null) queryParams.add('month=$month');
    if (status != null && status.isNotEmpty && status != 'All Posts') {
      queryParams.add('status=${status.toUpperCase()}');
    }
    if (contentType != null && contentType.isNotEmpty) {
      queryParams.add('contentType=${contentType.toUpperCase()}');
    }
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');

    if (queryParams.isEmpty) return '/api/v1/calendar/drafts';
    return '/api/v1/calendar/drafts?${queryParams.join('&')}';
  }

  static String calendarDraftSchedule(dynamic id) =>
      '/api/v1/calendar/drafts/$id/schedule';
  static String calendarDraftStatus(dynamic id) =>
      '/api/v1/calendar/drafts/$id/status';

  // --- Auth Endpoints (aliases & extended) ---
  static const String refresh = '/api/v1/auth/refresh';
  static const String register = '/api/v1/auth/register';
  static const String magicLinkRequest = '/api/v1/auth/magic-link/request';
  static const String magicLinkVerify = '/api/v1/auth/magic-link/verify';
  static const String sendEmailOtp = '/api/v1/auth/email-otp/send';
  static const String verifyEmailOtp = '/api/v1/auth/email-otp/verify';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String changePassword = '/api/v1/auth/password';

  // --- Creator Profile Endpoints ---
  static const String creatorProfile = '/api/v1/creators/me/profile';
  static const String updateCreatorProfile = '/api/v1/creators/me/profile';

  // --- Platform Auth & Disconnect Endpoints ---
  static String platformAuthUrl(String platform) =>
      '/api/v1/creators/me/connections/${platform.toUpperCase()}/auth-url';
  static String disconnectConnectionAccount(dynamic accountId) =>
      '/api/v1/creators/me/connections/accounts/$accountId';
  static String disconnectPlatform(String platform) =>
      '/api/v1/creators/me/connections/${platform.toUpperCase()}';

  // --- Notifications Endpoints ---
  static const String notifications = '/api/v1/notifications';
  static const String notificationsUnreadCount = '/api/v1/notifications/unread-count';
  static String markNotificationRead(dynamic id) => '/api/v1/notifications/$id/read';
  static const String markAllNotificationsRead = '/api/v1/notifications/read-all';
  static String deleteNotification(dynamic id) => '/api/v1/notifications/$id';

  // --- Chat Endpoints ---
  static const String chats = '/api/v1/chats';
  static String chatDetails(String chatId) => '/api/v1/chats/$chatId';
  static String chatMessages(String chatId) => '/api/v1/chats/$chatId/messages';

  // --- Dashboard Audit Endpoint ---
  static const String dashboardAudit = '/api/v1/dashboard/audit';

  // --- Public Documents & FAQs Endpoints ---
  static const String publicPrivacy = '/api/v1/public/documents/privacy';
  static const String publicTerms = '/api/v1/public/documents/terms';
  static const String publicFaqs = '/api/v1/public/faqs';

  // --- Trends Feed Endpoints ---
  static const String trends = '/api/v1/trends';
  static String trendDetails(dynamic id) => '/api/v1/trends/$id';

  // --- Pixo AI Orchestration Endpoints (M10) ---
  /// Main SSE streaming endpoint.  POST with { conversationId?, message }.
  static const String pixoStream = '/api/v1/pixo/stream';

  /// Fetch persisted messages for recovery reconciliation after a disconnect.
  /// Never re-POST to pixoStream for recovery — use this instead.
  static String pixoConversationMessages(dynamic conversationId) =>
      '/api/v1/pixo/conversations/$conversationId/messages';

  /// Option B cancellation — halts backend LLM consumption server-side.
  static String pixoCancelMessage(dynamic conversationId, dynamic messageId) =>
      '/api/v1/pixo/conversations/$conversationId/messages/$messageId/cancel';

  /// List all Pixo conversations for the sidebar.
  static const String pixoConversations = '/api/v1/pixo/conversations';

  /// Single conversation detail.
  static String pixoConversationDetail(dynamic conversationId) =>
      '/api/v1/pixo/conversations/$conversationId';

  // --- Support Tickets Endpoints ---
  static const String supportTickets = '/api/v1/support/tickets';
  static String supportTicketDetail(dynamic ticketId) =>
      '/api/v1/support/tickets/$ticketId';
  static String supportTicketReply(dynamic ticketId) =>
      '/api/v1/support/tickets/$ticketId/reply';
}
