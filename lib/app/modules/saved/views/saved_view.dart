import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/saved_model.dart';
import 'package:lala_ai/app/modules/saved/controllers/saved_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class SavedView extends GetView<SavedController> {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CC.background,
      appBar: CW.commonAppbar(
        wantBackIcon: false,
        titleWidget: Row(
          children: [
            Icon(Icons.bookmark_border_rounded, color: CC.primary, size: 20),
            8.width,
            Text("Saved Workspace", style: TS.sectionTitle(fontSize: 16)),
          ],
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(strokeWidth: 2, color: CC.primary));
          }

          final list = controller.savedItems;
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 40, color: CC.grey),
                  12.height,
                  Text("No saved topics yet.", style: TS.sectionTitle(color: CC.textPrimary)),
                  4.height,
                  Text("Explore Trending & Discover to save items.", style: TS.caption(color: CC.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return _buildSavedCard(context, item);
            },
          );
        }),
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, SavedItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.bookmark_rounded, color: CC.primary, size: 20),
          ),
          title: Text(item.title, style: TS.bodyMedium(color: CC.textPrimary, fontWeight: FontWeight.w600)),
          subtitle: Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TS.caption(color: CC.textSecondary)),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 18, color: CC.error),
            tooltip: "Remove from saved",
            onPressed: () => controller.removeItem(item.id),
          ),
        ),
      ),
    );
  }
}
