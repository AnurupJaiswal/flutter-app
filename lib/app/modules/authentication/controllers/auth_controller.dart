import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/modules/authentication/views/forgot_password_view.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'dart:io';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  final isLoginTab = true.obs;
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isEmailSent = false.obs;
  final errorMessage = ''.obs;

  // Form Validation Keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // Login Form Controllers
  late TextEditingController loginEmailController;
  late TextEditingController loginPasswordController;

  // Sign Up Form Controllers
  late TextEditingController signupNameController;
  late TextEditingController signupEmailController;
  late TextEditingController signupPasswordController;

  @override
  void onInit() {
    super.onInit();
    loginEmailController = TextEditingController();
    loginPasswordController = TextEditingController();
    signupNameController = TextEditingController();
    signupEmailController = TextEditingController();
    signupPasswordController = TextEditingController();
    // Clear stored credentials without destroying active UI controllers
    ApiService.clearSessionData();
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    super.onClose();
  }

  void toggleTab(bool login) {
    CM.unFocus(Get.context!);
    isLoginTab.value = login;
    isEmailSent.value = false;
    errorMessage.value = '';
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> signIn() async {
    // Validate form fields to trigger field-level error labels directly below empty fields
    if (!(loginFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    CM.unFocus(Get.context!);
    errorMessage.value = '';
    isLoading.value = true;

    // Clear any previous session credentials before attempting login
    await ApiService.clearSessionData();

    final response = await authRepository.login(email: email, password: password);
    isLoading.value = false;

    if (response.isSuccess) {
      CM.showToast("Welcome back, ${response.data?.user?.effectiveDisplayName ?? 'User'}!");
      Get.offAllNamed(Routes.MAIN_CONTAINER);
    } else {
      errorMessage.value = response.message;
      CM.showToast(response.message, isError: true);
    }
  }

  /// Passwordless Email Sign-Up Flow
  Future<void> signUp() async {
    if (!(signupFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = signupEmailController.text.trim();

    CM.unFocus(Get.context!);
    errorMessage.value = '';
    isLoading.value = true;

    final response = await authRepository.requestMagicLink(email);
    isLoading.value = false;

    if (response.isSuccess) {
      isEmailSent.value = true;
      CM.showToast("Secure sign-up link sent to $email");
    } else {
      CM.showToast(response.message, isError: true);
    }
  }

  Future<void> resendEmailLink() async {
    final email = signupEmailController.text.trim();
    if (email.isEmpty) return;
    
    isLoading.value = true;
    final response = await authRepository.requestMagicLink(email);
    isLoading.value = false;

    if (response.isSuccess) {
      CM.showToast("Verification link resent to $email");
    } else {
      CM.showToast(response.message, isError: true);
    }
  }

  void changeSignUpEmail() {
    isEmailSent.value = false;
  }

  Future<void> openSignupWebsite() async {
    const signupUrl = "https://pole-optimization-build-cultures.trycloudflare.com/auth/get-started?redirect=/checkout";
    final Uri url = Uri.parse(signupUrl);

    try {
      if (Platform.isAndroid) {
        final chromeIntent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: signupUrl,
          package: 'com.android.chrome',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        try {
          await chromeIntent.launch();
          return;
        } catch (_) {}
      }
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        CM.showToast("Could not open the website.");
      }
    } catch (e) {
      CM.showToast("Could not open the website.");
    }
  }

  Future<void> openEmailApp() async {
    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          category: 'android.intent.category.APP_EMAIL',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } else if (Platform.isIOS) {
        final Uri emailLaunchUri = Uri(scheme: 'message');
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
        } else {
          CM.showToast("Could not find an email app. Please open it manually.");
        }
      } else {
        CM.showToast("Please open your Email app to view the link.");
      }
    } catch (e) {
      CM.showToast("Could not open email app. Please open it manually.");
    }
  }

  void quickDemoLogin() {
    loginEmailController.text = "user@lala.ai";
    loginPasswordController.text = "password123";
    signIn();
  }

  void signInWithGoogle() {
    CM.showToast("Google Sign-In selected");
  }

  void signInWithMicrosoft() {
    CM.showToast("Microsoft Sign-In selected");
  }

  void forgotPassword() {
    Get.to(() => const ForgotPasswordView());
  }
}
