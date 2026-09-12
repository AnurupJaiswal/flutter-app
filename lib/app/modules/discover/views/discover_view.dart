import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/discover_model.dart';
import 'package:lala_ai/app/modules/discover/controllers/discover_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CC.background,
      appBar: CW.commonAppbar(
        wantBackIcon: false,
        titleWidget: Row(
          children: [
            Icon(Icons.explore_outlined, color: CC.primary, size: 20),
            8.width,
            Text("Discover & Search", style: TS.sectionTitle(fontSize: 16)),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Global Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: CW.commonSearchField(
                hintText: "Search topics, trends, news...",
                onChanged: (val) {
                  controller.searchQuery.value = val;
                  controller.search();
                },
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Obx(() => Row(
                    children: controller.categories.map((cat) {
                      final isSelected = controller.selectedCategory.value == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => controller.selectCategory(cat),
                          selectedColor: CC.tealSubtle,
                          backgroundColor: CC.surface,
                          side: BorderSide(color: isSelected ? CC.primary : CC.stroke, width: 0.7),
                          labelStyle: TS.caption(
                            color: isSelected ? CC.primary : CC.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  )),
            ),

            Divider(color: CC.stroke, height: 12, thickness: 0.7),

            // Search Results List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator(strokeWidth: 2, color: CC.primary));
                }

                final list = controller.items;
                if (list.isEmpty) {
                  return Center(child: Text("No items found.", style: TS.caption(color: CC.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildDiscoverCard(context, item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverCard(BuildContext context, DiscoverItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CC.stroke, width: 0.7),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: CC.tealSubtle,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.category.toUpperCase(),
                style: TS.caption(color: CC.primary, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
            const Spacer(),
            Text(item.source, style: TS.caption(color: CC.grey, fontSize: 10)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            6.height,
            Text(item.title, style: TS.sectionTitle(fontSize: 14, color: CC.textPrimary)),
            4.height,
            Text(item.description, style: TS.bodySmall(color: CC.textSecondary)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.bookmark_border_rounded, size: 18, color: CC.primary),
          tooltip: "Save item",
          onPressed: () => controller.bookmarkItem(item),
        ),
      ),
    );
  }
}
