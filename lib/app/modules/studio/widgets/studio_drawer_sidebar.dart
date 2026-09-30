import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/app/modules/studio/controllers/studio_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class StudioDrawerSidebar extends GetView<StudioController> {
  const StudioDrawerSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CC.surface,
      elevation: 0,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CC.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.movie_creation_outlined, color: CC.primary, size: 16),
                  ),
                  10.width,
                  Text("AI Studio", style: TS.sectionTitle(fontSize: 15)),
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

            16.height,

            // ── New Chat Button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CW.commonBtn(
                title: "New Chat",
                height: 44,
                leadingImage: const Icon(Icons.add_rounded, size: 18, color: CC.whiteText),
                onTap: () {
                  _closeDrawer(context);
                  controller.startNewChat();
                },
              ),
            ),

            20.height,

            // ── History List ─────────────────────────────────────────────
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, color: CC.grey, size: 32),
                        12.height,
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? "No matching chats"
                              : "No history yet",
                          style: TS.caption(color: CC.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 6, top: 4, bottom: 6),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: TS.caption(
                              color: CC.grey,
                              fontSize: 10,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ...entry.value.map((session) => _buildChatItem(context, session)),
                        8.height,
                      ],
                    );
                  }).toList(),
                );
              }),
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
              ? CC.primary.withValues(alpha: CC.isDark ? 0.18 : 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            _closeDrawer(context);
            controller.openChat(session);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 14,
                  color: isActive ? CC.primary : CC.textSecondary,
                ),
                10.width,
                Expanded(
                  child: Text(
                    session.title.trim().isNotEmpty
                        ? session.title
                        : "New Conversation",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.bodySmall(
                      color: isActive ? CC.primary : CC.textPrimary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                // More options
                _buildMoreMenu(context, session),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMoreMenu(BuildContext context, ChatSessionModel session) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, size: 15, color: CC.grey),
      splashRadius: 14,
      padding: EdgeInsets.zero,
      color: CC.surface,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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
          height: 36,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 14, color: CC.textSecondary),
              8.width,
              Text("Rename", style: TS.bodySmall(color: CC.textPrimary)),
            ],
          ),
        ),
        const PopupMenuDivider(height: 0.5),
        PopupMenuItem(
          value: 'delete',
          height: 36,
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 14, color: CC.error),
              8.width,
              Text("Delete", style: TS.bodySmall(color: CC.error)),
            ],
          ),
        ),
      ],
    );
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
