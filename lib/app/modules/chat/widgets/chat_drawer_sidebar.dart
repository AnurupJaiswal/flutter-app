import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/app/modules/chat/controllers/chat_controller.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class ChatDrawerSidebar extends GetView<ChatController> {
  const ChatDrawerSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CC.surface,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar: Minimal Brand Mark + Close
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
              child: Row(
                children: [
                  CW.aiAvatar(size: 24, isAssistant: true),
                  8.width,
                  Text(
                    "Lala Ai",
                    style: TS.sectionTitle(fontSize: 14),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: CC.textSecondary, size: 18),
                    splashRadius: 16,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _closeDrawer(context),
                  ),
                ],
              ),
            ),

            // 2. New Chat Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: CW.commonBtn(
                title: "New Chat",
                height: 42,
                leadingImage: const Icon(Icons.add_rounded, size: 18, color: CC.whiteText),
                onTap: () {
                  _closeDrawer(context);
                  controller.startNewChat();
                },
              ),
            ),
            8.height,

            // 4. Chronological Flat List
            Expanded(
              child: Obx(() {
                if (controller.isChatsLoading.value) {
                  return CW.skeletonList(
                    itemCount: 5,
                    itemHeight: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  );
                }

                final grouped = controller.groupedChats;

                if (grouped.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        controller.searchQuery.value.isNotEmpty
                            ? "No matching chats."
                            : "No history yet.",
                        style: TS.caption(color: CC.grey),
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: TS.caption(
                              color: CC.grey,
                              fontSize: 10.5,
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ...entry.value.map((session) => _buildChatItem(context, session)),
                      ],
                    );
                  }).toList(),
                );
              }),
            ),

            Divider(color: CC.stroke, height: 1, thickness: 0.7),

            // 5. User Profile Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: CC.surface,
              child: Row(
                children: [
                  CW.aiAvatar(
                    size: 26,
                    isAssistant: false,
                    userInitial: ApiService.effectiveDisplayName.isNotEmpty
                        ? ApiService.effectiveDisplayName[0].toUpperCase()
                        : "U",
                  ),
                  8.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ApiService.effectiveDisplayName,
                          style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          ApiService.userEmail ?? "user@lala.ai",
                          style: TS.caption(color: CC.textSecondary, fontSize: 10.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatSessionModel session) {
    return Obx(() {
      final isActive = controller.activeChat.value?.id == session.id;

      return Container(
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isActive
              ? (CC.isDark ? CC.whiteText.withValues(alpha: 0.1) : CC.primary.withValues(alpha: 0.12))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Icon(
            Icons.chat_bubble_outline_rounded,
            size: 15,
            color: isActive ? CC.primary : CC.textSecondary,
          ),
          title: Text(
            session.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TS.bodySmall(
              color: isActive ? (CC.isDark ? CC.textPrimary : CC.primary) : CC.textPrimary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz_rounded, size: 16, color: CC.grey),
            splashRadius: 14,
            padding: EdgeInsets.zero,
            color: CC.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: CC.stroke, width: 0.7),
            ),
            onSelected: (val) {
              if (val == 'rename') {
                _showRenameBottomSheet(context, session);
              } else if (val == 'delete') {
                _showDeleteBottomSheet(context, session);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'rename',
                height: 34,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 14, color: CC.textSecondary),
                    8.width,
                    Text("Rename", style: TS.bodySmall(color: CC.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                height: 34,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 14, color: CC.error),
                    8.width,
                    Text("Delete", style: TS.bodySmall(color: CC.error)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            _closeDrawer(context);
            controller.openChat(session);
          },
        ),
      );
    });
  }

  void _closeDrawer(BuildContext context) {
    try {
      if (Scaffold.of(context).isDrawerOpen) {
        Scaffold.of(context).closeDrawer();
        return;
      }
    } catch (_) {}
    Navigator.of(context).maybePop();
  }

  void _showRenameBottomSheet(BuildContext context, ChatSessionModel session) {
    _closeDrawer(context);
    CW.showRenameBottomSheet(
      context: context,
      initialTitle: session.title,
      onSave: (newTitle) {
        controller.renameSession(session, newTitle);
      },
    );
  }

  void _showDeleteBottomSheet(BuildContext context, ChatSessionModel session) {
    _closeDrawer(context);
    CW.showConfirmationBottomSheet(
      context: context,
      title: "Delete Chat",
      subtitle: "This action cannot be undone",
      message: "Are you sure you want to delete \"${session.title}\"?",
      confirmLabel: "Delete",
      confirmButtonColor: CC.error,
      icon: Icons.delete_outline_rounded,
      iconColor: CC.error,
      onConfirm: () {
        controller.deleteSession(session);
      },
    );
  }
}
