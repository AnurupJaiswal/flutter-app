import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/settings/views/settings_view.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/utils/common_methods.dart';

class AppNavigationService extends GetxService {
  static AppNavigationService get to => Get.find<AppNavigationService>();

  // Primary Tab Index Constants
  static const int tabDashboard = 0;
  static const int tabStudio = 1;
  static const int tabTrends = 2;
  static const int tabCalendar = 3;
  static const int tabProfile = 4;

  // 5 Independent Navigator Keys for each Bottom Navigation Tab
  final Map<int, GlobalKey<NavigatorState>> tabNavigatorKeys = {
    tabDashboard: GlobalKey<NavigatorState>(debugLabel: 'DashboardTabKey'),
    tabStudio: GlobalKey<NavigatorState>(debugLabel: 'StudioTabKey'),
    tabTrends: GlobalKey<NavigatorState>(debugLabel: 'TrendsTabKey'),
    tabCalendar: GlobalKey<NavigatorState>(debugLabel: 'CalendarTabKey'),
    tabProfile: GlobalKey<NavigatorState>(debugLabel: 'ProfileTabKey'),
  };

  // Debouncing lock to prevent rapid duplicate pushes
  DateTime? _lastNavigatedTime;
  static const Duration _debounceDuration = Duration(milliseconds: 350);

  bool _isNavigatingFast() {
    final now = DateTime.now();
    if (_lastNavigatedTime != null && now.difference(_lastNavigatedTime!) < _debounceDuration) {
      return true;
    }
    _lastNavigatedTime = now;
    return false;
  }

  /// Get the active navigator key for a given tab index
  GlobalKey<NavigatorState>? getTabNavigatorKey(int tabIndex) {
    return tabNavigatorKeys[tabIndex];
  }

  /// Get readable tab name for logging and debugging
  String getTabName(int tabIndex) {
    switch (tabIndex) {
      case tabDashboard:
        return 'Dashboard';
      case tabStudio:
        return 'Studio';
      case tabTrends:
        return 'Trends';
      case tabCalendar:
        return 'Calendar';
      case tabProfile:
        return 'Me';
      default:
        return 'Tab$tabIndex';
    }
  }

  /// Pop nested route within a tab to its root
  void popToTabRoot(int tabIndex) {
    final key = tabNavigatorKeys[tabIndex];
    if (key?.currentState != null && key!.currentState!.canPop()) {
      key.currentState!.popUntil((route) => route.isFirst);
    }
  }

  /// Navigate to nested screen inside active tab stack
  Future<T?>? pushNestedRoute<T>(int tabIndex, Widget page) {
    if (_isNavigatingFast()) return null;
    final key = tabNavigatorKeys[tabIndex];
    if (key?.currentState != null) {
      return key!.currentState!.push<T>(
        MaterialPageRoute(builder: (_) => page),
      );
    }
    return null;
  }

  /// Android & iOS System Back Button Handler for MainContainer Shell
  Future<bool> handleSystemBack(int currentTabIndex, Function(int) onSwitchToDefaultTab) async {
    // 1. If a dialog, bottom sheet, or modal is currently open, dismiss it first
    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      Get.back();
      return false;
    }

    final currentKey = tabNavigatorKeys[currentTabIndex];

    // 2. Check if the current active tab's nested navigator can pop a nested screen
    if (currentKey?.currentState != null && currentKey!.currentState!.canPop()) {
      currentKey.currentState!.pop();
      return false; // Do not exit app, nested route was popped
    }

    // 3. If at root of a non-default tab, switch back to Default Tab (Dashboard / Tab 0)
    if (currentTabIndex != tabDashboard) {
      onSwitchToDefaultTab(tabDashboard);
      return false; // Do not exit app, switched to default tab
    }

    // 4. If already at root of Default Tab (Dashboard / Tab 0), allow system exit
    return true;
  }

  /// Authentication Flow Stack Management: Clear all stacks on successful login
  void navigateToMainContainer() {
    Get.offAllNamed(Routes.MAIN_CONTAINER);
  }

  /// Authentication Flow Stack Management: Clear all stacks on logout
  void navigateToAuth() {
    Get.offAllNamed(Routes.AUTHENTICATION);
  }

  /// Deep Link Handler: Format myapp://route
  void handleDeepLink(Uri uri, Function(int) onTabChange) {
    final path = uri.path.toLowerCase();
    CM.log(msg: "Handling deep link path: $path");

    if (path.contains("settings")) {
      onTabChange(tabProfile);
      pushNestedRoute(tabProfile, const SettingsView());
    } else if (path.contains("studio")) {
      onTabChange(tabStudio);
    } else if (path.contains("trends")) {
      onTabChange(tabTrends);
    } else if (path.contains("calendar")) {
      onTabChange(tabCalendar);
    } else {
      onTabChange(tabDashboard);
    }
  }
}

/// NavigatorObserver for tab-nested routes to log pushes and pops
class TabNavigatorObserver extends NavigatorObserver {
  final String tabName;
  TabNavigatorObserver(this.tabName);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final routeName = route.settings.name ?? route.runtimeType.toString();
    debugPrint("NAV PUSH: $routeName | CURRENT NAVIGATOR: ${tabName}Navigator | BOTTOM TAB: $tabName");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final routeName = route.settings.name ?? route.runtimeType.toString();
    debugPrint("NAV POP: $routeName | CURRENT NAVIGATOR: ${tabName}Navigator | BOTTOM TAB: $tabName");
  }
}
