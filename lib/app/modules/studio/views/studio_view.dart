import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/app/modules/profile/views/profile_view.dart';
import 'package:lala_ai/app/modules/main_container/controllers/main_container_controller.dart';
import 'package:lala_ai/app/modules/studio/controllers/studio_controller.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class StudioView extends GetView<StudioController> {
  const StudioView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StudioController>()) {
      Get.put(StudioController());
    }

    return GetBuilder<ThemeService>(
      builder: (themeService) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: false,
            wantBackIcon: false,
            title: "AI Content Studio",
            actions: [
              IconButton(
                icon: Icon(Icons.person_outline_rounded, color: CC.textPrimary, size: 22),
                splashRadius: 20,
                onPressed: () => Get.to(() => const ProfileView()),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Generator Mode Switcher
                  Obx(() => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CC.isDark ? CC.darkBg2 : CC.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CC.isDark ? CC.black.withValues(alpha: 0.4) : CC.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _modeTab("Script Generator", 0)),
                        Expanded(child: _modeTab("Hooks & Keywords", 1)),
                      ],
                    ),
                  )),
                  16.height,

                  // Dynamic Tab View
                  Obx(() {
                    if (controller.activeTab.value == 0) {
                      return _buildScriptGenerator();
                    } else {
                      return _buildHooksGenerator();
                    }
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _modeTab(String title, int index) {
    final isSelected = controller.activeTab.value == index;
    return GestureDetector(
      onTap: () => controller.activeTab.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? CC.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TS.caption(
            color: isSelected ? CC.whiteText : CC.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SCRIPT GENERATOR
  // ===========================================================================
  Widget _buildScriptGenerator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form Inputs Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CC.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CC.isDark ? CC.black.withValues(alpha: 0.45) : CC.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Topic / Concept", style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w600)),
              6.height,
              TextFormField(
                style: TS.bodySmall(color: CC.textPrimary),
                decoration: InputDecoration(
                  hintText: "e.g., How to automate YouTube thumbnails using AI",
                  filled: true,
                  fillColor: CC.inputBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: CC.stroke.withValues(alpha: 0.5), width: 0.7),
                  ),
                ),
              ),
              12.height,
              Row(
                children: [
                  Expanded(
                    child: _dropdownSelector("Platform", ["YouTube Shorts", "Instagram Reel", "YouTube Video"]),
                  ),
                  10.width,
                  Expanded(
                    child: _dropdownSelector("Tone", ["Energetic", "Informative", "Viral Storytelling"]),
                  ),
                ],
              ),
              14.height,
              Obx(() => CW.commonBtn(
                title: "Generate AI Script",
                isLoading: controller.isGeneratingScript.value,
                onTap: controller.generateScript,
              )),
            ],
          ),
        ),
        16.height,

        // Expandable Result Card
        Text("Generated Result", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
        10.height,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CC.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CC.isDark ? CC.black.withValues(alpha: 0.45) : CC.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Obx(() => Text(
                      controller.generatedScriptTitle.value,
                      style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
                    )),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: 18, color: CC.primary),
                    tooltip: "Copy Script",
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: "${controller.generatedScriptTitle}\n\n${controller.generatedScriptHook}\n\n${controller.generatedScriptBody}\n\n${controller.generatedScriptCTA}"));
                      AppToast.success("Script copied to clipboard!");
                    },
                  ),
                ],
              ),
              const Divider(height: 16, thickness: 0.7),
              _scriptSection("HOOK (0-3s)", controller.generatedScriptHook.value, CC.primary),
              10.height,
              _scriptSection("BODY", controller.generatedScriptBody.value, CC.textPrimary),
              10.height,
              _scriptSection("CALL TO ACTION (CTA)", controller.generatedScriptCTA.value, CC.success),
              14.height,
              Row(
                children: [
                  Expanded(
                    child: CW.commonBtn(
                      title: "Push to Calendar",
                      isOutlined: true,
                      onTap: () => Get.find<MainContainerController>().changeTab(AppNavigationService.tabCalendar),
                    ),
                  ),
                  10.width,
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, color: CC.primary, size: 20),
                    tooltip: "Micro-Regenerate",
                    onPressed: controller.generateScript,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dropdownSelector(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w600)),
        4.height,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: CC.inputBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.first,
              isExpanded: true,
              style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w600),
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _scriptSection(String header, String content, Color headerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: TS.caption(color: headerColor, fontWeight: FontWeight.w700)),
        4.height,
        Text(content, style: TS.bodySmall(color: CC.textSecondary)),
      ],
    );
  }

  // ===========================================================================
  // HOOKS & KEYWORDS GENERATOR
  // ===========================================================================
  Widget _buildHooksGenerator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CC.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CC.isDark ? CC.black.withValues(alpha: 0.45) : CC.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Niche / Core Topic", style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w600)),
              6.height,
              TextFormField(
                style: TS.bodySmall(color: CC.textPrimary),
                decoration: InputDecoration(
                  hintText: "e.g., YouTube monetization tips for small creators",
                  filled: true,
                  fillColor: CC.inputBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: CC.stroke.withValues(alpha: 0.5), width: 0.7),
                  ),
                ),
              ),
              12.height,
              Obx(() => CW.commonBtn(
                title: "Generate Viral Hooks & Keywords",
                isLoading: controller.isGeneratingHooks.value,
                onTap: controller.generateHooks,
              )),
            ],
          ),
        ),
        16.height,

        Text("High-Converting Hooks", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
        10.height,
        Obx(() => Column(
          children: controller.generatedHooks.map((hook) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CC.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CC.isDark ? CC.black.withValues(alpha: 0.45) : CC.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CC.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.auto_awesome_rounded, color: CC.textPrimary, size: 18),
                  ),
                  12.width,
                  Expanded(child: Text(hook, style: TS.bodySmall(color: CC.textPrimary))),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: 18, color: CC.textSecondary),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: hook));
                      AppToast.success("Hook copied!");
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        )),
        14.height,

        Text("Recommended Keywords & Hashtags", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
        10.height,
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.generatedKeywords.map((kw) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CC.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(kw, style: TS.caption(color: CC.primary, fontWeight: FontWeight.w600)),
            );
          }).toList(),
        )),
      ],
    );
  }
}
