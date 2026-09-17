// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:lala_ai/app/modules/analytics/bindings/analytics_binding.dart';
import 'package:lala_ai/app/modules/analytics/views/analytics_view.dart';
import 'package:lala_ai/app/modules/authentication/bindings/auth_binding.dart';
import 'package:lala_ai/app/modules/authentication/views/authentication_view.dart';
import 'package:lala_ai/app/modules/authentication/views/reset_password_view.dart';
import 'package:lala_ai/app/modules/calendar/views/calendar_view.dart';
import 'package:lala_ai/app/modules/chat/bindings/chat_binding.dart';
import 'package:lala_ai/app/modules/chat/views/chat_conversation_view.dart';
import 'package:lala_ai/app/modules/chat/views/chat_home_view.dart';
import 'package:lala_ai/app/modules/competitor/views/competitor_view.dart';
import 'package:lala_ai/app/modules/connect_accounts/views/connect_accounts_view.dart';
import 'package:lala_ai/app/modules/main_container/bindings/main_container_binding.dart';
import 'package:lala_ai/app/modules/main_container/views/main_container_view.dart';
import 'package:lala_ai/app/modules/profile/views/profile_view.dart';
import 'package:lala_ai/app/modules/settings/bindings/settings_binding.dart';
import 'package:lala_ai/app/modules/settings/views/legal_webview_view.dart';
import 'package:lala_ai/app/modules/settings/views/settings_view.dart';
import 'package:lala_ai/app/modules/splash/bindings/splash_binding.dart';
import 'package:lala_ai/app/modules/splash/views/splash_view.dart';
import 'package:lala_ai/app/modules/studio/views/studio_view.dart';
import 'package:lala_ai/app/modules/welcome/bindings/welcome_binding.dart';
import 'package:lala_ai/app/modules/welcome/views/welcome_view.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/app/routes/auth_middleware.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
      transition: Transition.fadeIn,
      middlewares: [GuestGuardMiddleware()],
    ),
    GetPage(
      name: Routes.AUTHENTICATION,
      page: () => const AuthenticationView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      middlewares: [GuestGuardMiddleware()],
    ),
    GetPage(
      name: Routes.MAIN_CONTAINER,
      page: () => const MainContainerView(),
      binding: MainContainerBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.CHAT_HOME,
      page: () => const ChatHomeView(),
      binding: ChatBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.CHAT_CONVERSATION,
      page: () => const ChatConversationView(),
      binding: ChatBinding(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.STUDIO,
      page: () => const StudioView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.CALENDAR,
      page: () => const CalendarView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.CONNECT_ACCOUNTS,
      page: () => const ConnectAccountsView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.COMPETITOR,
      page: () => const CompetitorView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.PRIVACY_POLICY,
      page: () => const LegalWebViewView(
        title: "Privacy Policy",
        isPrivacyPolicy: true,
        htmlData: '''
        <h1>Privacy Policy</h1>
        <div class="subtitle">Effective Date: September 2026 | Lala AI Legal Center</div>
        <h2>1. Information Collection</h2>
        <p>Lala AI collects channel analytics, prompt inputs, and user configuration settings to deliver personalized AI script generation and metrics tracking.</p>
        <h2>2. Data Security & Storage</h2>
        <p>All transmitted data is protected using AES-256 SSL encryption. Your credentials and channel data are never shared with third parties.</p>
        <h2>3. Rights & Export</h2>
        <p>You can export your dataset or request permanent account deletion at any time in Settings.</p>
        ''',
      ),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.TERMS_CONDITIONS,
      page: () => const LegalWebViewView(
        title: "Terms & Conditions",
        isPrivacyPolicy: false,
        htmlData: '''
        <h1>Terms & Conditions</h1>
        <div class="subtitle">Effective Date: September 2026 | Lala AI Legal Center</div>
        <h2>1. Agreement to Terms</h2>
        <p>By registering or using Lala AI, you agree to comply with all platform terms, acceptable use policies, and subscription guidelines.</p>
        <h2>2. Intellectual Property</h2>
        <p>All content and AI scripts produced via Lala AI remain 100% owned by the creator.</p>
        <h2>3. Billing & Cancellation</h2>
        <p>Subscriptions renew automatically each cycle. You can manage or cancel your subscription anytime in Settings.</p>
        ''',
      ),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      transition: Transition.fadeIn,
      middlewares: [GuestGuardMiddleware()],
    ),
  ];
}
