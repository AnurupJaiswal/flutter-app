import 'package:get/get.dart';

import '../../../../utils/app_toast.dart';

class StudioController extends GetxController {
  final activeTab = 0.obs; // 0 = Script Generator, 1 = Hooks & Keywords

  // Script Generator Inputs
  final topicController = "".obs;
  final selectedNiche = "Tech & AI".obs;
  final selectedPlatform = "YouTube Shorts".obs;
  final selectedTone = "Energetic & Engaging".obs;
  final isGeneratingScript = false.obs;

  // Generated Script Output
  final generatedScriptTitle = "10 Secret AI Tools to Automate Your Content in 2026".obs;
  final generatedScriptHook = "Stop spending 5 hours editing video titles manually. In 30 seconds, I'm showing you the exact AI system content creators are using.".obs;
  final generatedScriptBody = "Step 1: Open Pixo AI and paste your rough video outline.\nStep 2: Generate 5 high-converting hook options.\nStep 3: Auto-schedule your post for peak viewer retention.".obs;
  final generatedScriptCTA = "Comment 'PIXO' below and I'll send you the direct access link!".obs;

  // Hooks & Keywords Generator Inputs
  final hookTopicController = "".obs;
  final isGeneratingHooks = false.obs;
  final generatedHooks = <String>[
    "Nobody is talking about this 1 AI shortcut...",
    "This 1 trick saved me 20 hours of scripting this week.",
    "If you make content for YouTube or Instagram, stop scrolling right now.",
  ].obs;

  final generatedKeywords = <String>[
    "#LalaAI", "#PixoAI", "#CreatorTools", "#YouTubeGrowth", "#ReelsViral", "#ContentAutomation"
  ].obs;

  Future<void> generateScript() async {
    isGeneratingScript.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    isGeneratingScript.value = false;
    AppToast.success("Your new script is ready below!");
  }

  Future<void> generateHooks() async {
    isGeneratingHooks.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    isGeneratingHooks.value = false;
    AppToast.success("Fresh viral hooks generated!");
  }
}
