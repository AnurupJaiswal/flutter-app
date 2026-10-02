import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_response.dart';

class NotificationRepository {
  Future<ApiResponse> getNotifications({int page = 0, bool unreadOnly = false}) async {
    return await ApiService.get(
      '${ApiEndpoints.notifications}?page=$page&size=20&unreadOnly=$unreadOnly',
    );
  }

  Future<ApiResponse> getUnreadCount() async {
    return await ApiService.get(ApiEndpoints.notificationsUnreadCount);
  }

  Future<ApiResponse> markAsRead(dynamic id) async {
    return await ApiService.put(ApiEndpoints.markNotificationRead(id));
  }

  Future<ApiResponse> markAllAsRead() async {
    return await ApiService.put(ApiEndpoints.markAllNotificationsRead);
  }

  Future<ApiResponse> deleteNotification(dynamic id) async {
    return await ApiService.delete(ApiEndpoints.deleteNotification(id));
  }
}
