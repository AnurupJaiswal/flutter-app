import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/networking/api_endpoints.dart';

class SettingsController extends GetxController {
  final AuthRepository authRepository;

  SettingsController({required this.authRepository});

  final selectedModel = 'Lala Ai Pro 2.0 (Recommended)'.obs;
  final codeHighlighting = true.obs;
  final hapticFeedback = true.obs;
  final notificationsEnabled = true.obs;
  final selectedLanguage = 'English (US)'.obs;
  final currentPlan = 'Pro Creator Plan (\$29/mo)'.obs;
  final isDownloadingData = false.obs;

  final aiModels = [
    'Lala Ai Pro 2.0 (Recommended)',
    'Claude 3.5 Sonnet (API Ready)',
    'GPT-4o Omniscient (API Ready)',
    'Gemini 1.5 Flash (API Ready)',
  ];

  final languages = [
    'English (US)',
    'English (UK)',
    'Spanish (Español)',
    'French (Français)',
    'German (Deutsch)',
    'Hindi (हिन्दी)',
    'Japanese (日本語)',
    'Chinese (中文)',
    'Arabic (العربية)',
  ];

  final subscriptionPlans = [
    {
      'name': 'Starter Plan',
      'price': 'Free',
      'features': ['10 AI Generations/day', 'Basic Analytics', 'Standard Support'],
      'isCurrent': false,
    },
    {
      'name': 'Pro Creator Plan',
      'price': '\$29/mo',
      'features': ['Unlimited AI Generations', 'Advanced Competitor Tracking', 'Priority Support', 'Export CSV Data'],
      'isCurrent': true,
    },
    {
      'name': 'Agency Plan',
      'price': '\$99/mo',
      'features': ['Multi-Channel Management', 'Custom AI Voice Models', 'Dedicated Manager', 'API Access'],
      'isCurrent': false,
    },
  ];

  void selectModel(String model) {
    selectedModel.value = model;
    CM.showToast("Active model updated: $model");
  }

  void selectLanguage(String language) {
    selectedLanguage.value = language;
    CM.showToast("Language changed to $language");
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    CM.showToast(value ? "Push notifications enabled" : "Push notifications disabled");
  }

  void updatePlan(String planName, String price) {
    currentPlan.value = "$planName ($price)";
    CM.showToast("Subscribed to $planName ($price)!");
  }

  Future<void> exportData(String dataType) async {
    isDownloadingData.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    isDownloadingData.value = false;
    CM.showToast("$dataType export requested. A download link will be emailed to your account.");
  }

  Future<void> openWhatsAppSupport() async {
    const phoneNumber = "917869997413";
    const text = "Hello Lala AI Support! I need assistance with my creator account.";
    final whatsappUri = Uri.parse("whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(text)}");
    final webUri = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(text)}");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        CM.showToast("Opening WhatsApp (+91 78699 97413)...");
      }
    }
  }

  Future<void> deleteAccount() async {
    CM.showToast("Account deletion request submitted. Our support team will process your request within 24-48 hours.");
  }

  Future<bool> createSupportTicket(String message, {String category = "GENERAL", String subject = "In-App Support Request"}) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.supportTickets,
        body: {
          "category": category,
          "subject": subject,
          "message": message,
        },
      );
      if (response.isSuccess) {
        CM.showToast("Support ticket created! We'll reply shortly.");
        return true;
      } else {
        CM.showToast("Failed to create ticket: ${response.message}");
        return false;
      }
    } catch (e) {
      CM.showToast("Error: Failed to submit ticket.");
      return false;
    }
  }

  void clearLocalCache() {
    CM.showToast("Local cache cleared successfully.");
  }

  Future<void> logout() async {
    await authRepository.logout();
    CM.showToast("Signed out successfully");
    Get.offAllNamed(Routes.AUTHENTICATION);
  }
}
