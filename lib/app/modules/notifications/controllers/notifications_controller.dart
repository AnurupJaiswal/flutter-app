import 'package:get/get.dart';
import 'package:lala_ai/app/data/repositories/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:lala_ai/utils/common_widget.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();

  var isLoading = true.obs;
  var isPaginating = false.obs;
  var notifications = [].obs;
  var unreadCount = 0.obs;
  var currentPage = 0;
  var hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(refresh: true);
    fetchUnreadCount();
  }

  Future<void> fetchUnreadCount() async {
    final res = await _repository.getUnreadCount();
    if (res.success && res.data != null) {
      unreadCount.value = res.data['count'] ?? 0;
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      currentPage = 0;
      hasMore = true;
      isLoading.value = true;
      notifications.clear();
    } else {
      if (!hasMore || isPaginating.value) return;
      isPaginating.value = true;
    }

    try {
      final res = await _repository.getNotifications(page: currentPage);
      if (res.success && res.data != null) {
        final content = res.data['content'] as List? ?? [];
        if (content.isEmpty) {
          hasMore = false;
        } else {
          if (refresh) {
            notifications.assignAll(content);
          } else {
            notifications.addAll(content);
          }
          currentPage++;
        }
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
      isPaginating.value = false;
    }
  }

  Future<void> markAsRead(dynamic id, int index) async {
    final current = notifications[index];
    if (current['isRead'] == true) return; // Already read

    // Optimistic update
    notifications[index]['isRead'] = true;
    notifications.refresh();
    if (unreadCount.value > 0) unreadCount.value--;

    final res = await _repository.markAsRead(id);
    if (!res.success) {
      // Revert on failure
      notifications[index]['isRead'] = false;
      notifications.refresh();
      unreadCount.value++;
      AppToast.error("Failed to mark as read");
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic update
    for (var i = 0; i < notifications.length; i++) {
      notifications[i]['isRead'] = true;
    }
    notifications.refresh();
    unreadCount.value = 0;

    final res = await _repository.markAllAsRead();
    if (!res.success) {
      AppToast.error("Failed to mark all as read");
      fetchNotifications(refresh: true);
      fetchUnreadCount();
    }
  }

  Future<void> deleteNotification(dynamic id, int index) async {
    final removed = notifications[index];
    final wasUnread = removed['isRead'] != true;

    // Optimistic update
    notifications.removeAt(index);
    if (wasUnread && unreadCount.value > 0) unreadCount.value--;

    final res = await _repository.deleteNotification(id);
    if (!res.success) {
      // Revert on failure
      notifications.insert(index, removed);
      if (wasUnread) unreadCount.value++;
      AppToast.error("Failed to delete notification");
    } else {
      AppToast.info("Notification deleted");
    }
  }
}
