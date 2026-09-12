class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.lala.ai/v1';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String userProfile = '/user/profile';

  // Chat Endpoints
  static const String chats = '/chats';
  static String chatDetails(String chatId) => '/chats/$chatId';
  static String chatMessages(String chatId) => '/chats/$chatId/messages';
  static const String generateTitle = '/chats/generate-title';
}
