import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/extensions.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CC.background,
      appBar: AppBar(
        backgroundColor: CC.surface,
        elevation: 0,
        title: Text(
          "Notifications",
          style: TS.sectionTitle(color: CC.textPrimary, fontSize: 20),
        ),
        iconTheme: IconThemeData(color: CC.textPrimary),
        actions: [
          Obx(() {
            if (controller.notifications.isEmpty || controller.unreadCount.value == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: () => controller.markAllAsRead(),
              child: Text(
                "Mark all read",
                style: TS.bodyMedium(color: CC.primary, fontWeight: FontWeight.w600),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/img_notifcation_illustration.png",
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  16.height,
                  Text(
                    "No Notifications Yet",
                    style: TS.sectionTitle(color: CC.textPrimary, fontSize: 18).copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  8.height,
                  Text(
                    "When you receive updates, they'll show up here.",
                    style: TS.caption(color: CC.textSecondary).copyWith(
                      fontSize: 13,
                      height: 1.38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(refresh: true),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: controller.notifications.length + (controller.hasMore ? 1 : 0),
            separatorBuilder: (context, index) => Divider(color: CC.stroke.withValues(alpha: 0.3), height: 1),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                controller.fetchNotifications();
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final item = controller.notifications[index];
              final isRead = item['isRead'] == true;
              final title = item['title'] ?? "Notification";
              final message = item['message'] ?? "";
              final type = item['type'] ?? "INFO"; // INFO, WARNING, SUCCESS, ERROR
              
              IconData iconData = Icons.info_outline_rounded;
              Color iconColor = CC.primary;
              if (type == "WARNING") {
                iconData = Icons.warning_amber_rounded;
                iconColor = CC.insightful;
              } else if (type == "SUCCESS") {
                iconData = Icons.check_circle_outline_rounded;
                iconColor = CC.success;
              } else if (type == "ERROR") {
                iconData = Icons.error_outline_rounded;
                iconColor = CC.error;
              }

              return Dismissible(
                key: Key(item['id'].toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: CC.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (direction) {
                  controller.deleteNotification(item['id'], index);
                },
                child: InkWell(
                  onTap: () {
                    if (!isRead) controller.markAsRead(item['id'], index);
                  },
                  child: Container(
                    color: isRead ? Colors.transparent : CC.primary.withValues(alpha: 0.05),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, color: iconColor, size: 24),
                        ),
                        16.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TS.bodyMedium(
                                  color: CC.textPrimary,
                                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                ),
                              ),
                              if (message.isNotEmpty) ...[
                                4.height,
                                Text(
                                  message,
                                  style: TS.bodySmall(color: CC.textSecondary, height: 1.4),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!isRead) ...[
                          8.width,
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: CC.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
