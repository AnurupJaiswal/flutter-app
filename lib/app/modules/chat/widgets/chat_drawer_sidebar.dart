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
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),

            // 2. New Chat Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: CW.commonBtn(
                title: "New Chat",
                height: 40,
                leadingImage: const Icon(Icons.add_rounded, size: 18, color: CC.whiteText),
                onTap: () {
                  Navigator.of(context).maybePop();
                  controller.startNewChat();
                },
              ),
            ),

            // 3. Search Chat History Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: CW.commonSearchField(
                controller: controller.searchInputController,
                hintText: "Search history...",
                onChanged: (val) => controller.searchQuery.value = val,
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: Icon(Icons.clear_rounded, size: 14, color: CC.grey),
                    splashRadius: 14,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      controller.searchInputController.clear();
                      controller.searchQuery.value = '';
                    },
                  );
                }),
              ),
            ),

            Divider(color: CC.stroke, height: 12, thickness: 0.7),

            // 4. Chronological Flat List
            Expanded(
              child: Obx(() {
                if (controller.isChatsLoading.value) {
                  return Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(CC.primary),
                      ),
                    ),
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
                    userInitial: ApiService.userName?.isNotEmpty == true
                        ? ApiService.userName![0]
                        : "U",
                  ),
                  8.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ApiService.userName ?? "Lala Ai User",
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
          color: isActive ? CC.tealSubtle : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive
              ? Border.all(color: CC.primary.withValues(alpha: 0.3), width: 0.7)
              : null,
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: Text(
            session.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TS.bodySmall(
              color: isActive ? CC.primary : CC.textPrimary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
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
                _showRenameDialog(context, session);
              } else if (val == 'delete') {
                _showDeleteDialog(context, session);
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
            Navigator.of(context).maybePop();
            controller.openChat(session);
          },
        ),
      );
    });
  }

  void _showRenameDialog(BuildContext context, ChatSessionModel session) {
    final textController = TextEditingController(text: session.title);
    Get.dialog(
      AlertDialog(
        backgroundColor: CC.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: CC.stroke),
        ),
        title: Text("Rename Chat", style: TS.sectionTitle(color: CC.textPrimary)),
        content: CW.commonTextFormField(
          controller: textController,
          hintText: "Chat title",
          autoFocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TS.caption(color: CC.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CC.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              Get.back();
              controller.renameSession(session, textController.text);
            },
            child: Text("Save", style: TS.button(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChatSessionModel session) {
    Get.dialog(
      AlertDialog(
        backgroundColor: CC.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: CC.stroke),
        ),
        title: Text("Delete Chat", style: TS.sectionTitle(color: CC.textPrimary)),
        content: Text(
          "Are you sure you want to delete \"${session.title}\"?",
          style: TS.bodySmall(color: CC.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TS.caption(color: CC.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CC.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              Get.back();
              controller.deleteSession(session);
            },
            child: Text("Delete", style: TS.button(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
