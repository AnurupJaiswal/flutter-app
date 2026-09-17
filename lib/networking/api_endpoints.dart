class ApiEndpoints {
  ApiEndpoints._();

  // Use the cloudflare tunnel for development
  static const String baseUrl = 'https://hoped-studies-richmond-massive.trycloudflare.com';
  static const String signupUrl = 'https://pole-optimization-build-cultures.trycloudflare.com/auth/get-started?redirect=/checkout';

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

  static const String mobileCreateHandoff = '/api/v1/auth/mobile/create-handoff';
  static const String mobileExchangeHandoff = '/api/v1/auth/mobile/exchange-handoff';
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
}
