class ApiEndpoints {
  ApiEndpoints._();

  // Use the cloudflare tunnel for development
  // static const String baseUrl =
  //     'https://purple-primarily-coated-happens.trycloudflare.com';


   static const String baseUrl = 'https://guru-oklahoma-month-organize.trycloudflare.com';

  static const String signupUrl =
      'https://lala-ai-green.vercel.app/auth/get-started?redirect=/checkout';

  // --- Auth Endpoints ---
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String changePassword = '/api/v1/auth/password';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';

  static const String sendEmailOtp = '/api/v1/auth/email-otp/send';
  static const String verifyEmailOtp = '/api/v1/auth/email-otp/verify';
  static const String completeSetup = '/api/v1/auth/complete-setup';
  static const String me = '/api/v1/auth/me';

  static const String magicLinkRequest = '/api/v1/auth/magic-link/request';
  static const String magicLinkVerify = '/api/v1/auth/magic-link/verify';

  // --- Chat Endpoints ---
  static const String chats = '/api/v1/chats';
  static String chatDetails(String chatId) => '/api/v1/chats/$chatId';
  static String chatMessages(String chatId) => '/api/v1/chats/$chatId/messages';
  static const String generateTitle = '/api/v1/chats/generate-title';

  static const String subscriptionStatus = '/api/v1/subscriptions/status';
  static const String subscriptionPlans = '/api/v1/subscriptions/plans';

  // --- Creator Profile Endpoints ---
  static const String creatorProfile = '/api/v1/creators/me/profile';
  static const String updateCreatorProfile = '/api/v1/creators/me/profile';

  // --- Platform Connection Endpoints ---
  static const String creatorConnections = '/api/v1/creators/me/connections';
  static String platformAuthUrl(String platform) =>
      '/api/v1/creators/me/connections/${platform.toUpperCase()}/auth-url';
  static String disconnectConnectionAccount(dynamic id) =>
      '/api/v1/creators/me/connections/accounts/$id';
  static String disconnectPlatform(String platform) =>
      '/api/v1/creators/me/connections/${platform.toUpperCase()}';
  static String selectConnectionAccount(dynamic id) =>
      '/api/v1/creators/me/connections/accounts/$id/select';

  // --- Milestone 2: Channel Analytics & Dashboard Audit ---
  static String analyticsOverview(String platform, [String period = '30d']) =>
      '/api/v1/creators/me/analytics/${platform.toLowerCase()}/overview?period=$period';
  static String analyticsGrowth(String platform, [String period = '30d']) =>
      '/api/v1/creators/me/analytics/${platform.toLowerCase()}/growth?period=$period';
  static String analyticsEngagement(String platform, [String period = '30d']) =>
      '/api/v1/creators/me/analytics/${platform.toLowerCase()}/engagement?period=$period';
  static String analyticsActivity(String platform, [String period = '30d']) =>
      '/api/v1/creators/me/analytics/${platform.toLowerCase()}/activity?period=$period';
  static String analyticsTopContent(String platform, [String period = '30d', int limit = 5]) =>
      '/api/v1/creators/me/analytics/${platform.toLowerCase()}/top-content?period=$period&limit=$limit';

  // Specific Platform Analytics Aliases
  static String youtubeOverview([String period = '30d']) => analyticsOverview('youtube', period);
  static String youtubeGrowth([String period = '30d']) => analyticsGrowth('youtube', period);
  static String youtubeEngagement([String period = '30d']) => analyticsEngagement('youtube', period);
  static String youtubeActivity([String period = '30d']) => analyticsActivity('youtube', period);
  static String youtubeTopContent([String period = '30d', int limit = 5]) => analyticsTopContent('youtube', period, limit);

  static String instagramOverview([String period = '30d']) => analyticsOverview('instagram', period);
  static String instagramGrowth([String period = '30d']) => analyticsGrowth('instagram', period);
  static String instagramEngagement([String period = '30d']) => analyticsEngagement('instagram', period);
  static String instagramActivity([String period = '30d']) => analyticsActivity('instagram', period);
  static String instagramTopContent([String period = '30d', int limit = 5]) => analyticsTopContent('instagram', period, limit);

  // Dashboard & Audit Endpoints
  static String dashboardOverview(dynamic connectedAccountId) =>
      '/api/v1/dashboard/overview?connectedAccountId=$connectedAccountId';
  static const String dashboardAudit = '/api/v1/dashboard/audit';

  // Creator To-Dos Endpoints
  static String dashboardTodos([dynamic connectedAccountId]) =>
      connectedAccountId != null
          ? '/api/v1/dashboard/todos?connectedAccountId=$connectedAccountId'
          : '/api/v1/dashboard/todos';
  static const String dashboardTodosConvert = '/api/v1/dashboard/todos/convert';
  static String dashboardTodoUpdate(dynamic todoId) => '/api/v1/dashboard/todos/$todoId';
  static String dashboardTodoDelete(dynamic todoId) => '/api/v1/dashboard/todos/$todoId';
}
