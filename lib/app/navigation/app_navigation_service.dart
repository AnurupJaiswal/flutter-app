import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/core/deep_link/deep_link_router.dart';
import 'package:lala_ai/utils/common_widget.dart';

class AppNavigationService extends GetxService {
  static AppNavigationService get to => Get.find<AppNavigationService>();

  // Primary Tab Index Constants
  static const int tabDashboard = 0;
  static const int tabStudio = 1;
  static const int tabTrends = 2;
  static const int tabCalendar = 3;
  static const int tabDiscover = 4;

  // Reactive flag for modal/bottom-sheet overlay visibility
  final isOverlayOpen = false.obs;

  // 5 Independent Navigator Keys for each Bottom Navigation Tab
  final Map<int, GlobalKey<NavigatorState>> tabNavigatorKeys = {
    tabDashboard: GlobalKey<NavigatorState>(debugLabel: 'DashboardTabKey'),
    tabStudio: GlobalKey<NavigatorState>(debugLabel: 'StudioTabKey'),
    tabTrends: GlobalKey<NavigatorState>(debugLabel: 'TrendsTabKey'),
    tabCalendar: GlobalKey<NavigatorState>(debugLabel: 'CalendarTabKey'),
    tabDiscover: GlobalKey<NavigatorState>(debugLabel: 'DiscoverTabKey'),
  };

  // Cached TabNavigatorObserver instances to avoid recreating them on every build
  final Map<int, TabNavigatorObserver> _cachedObservers = {};

  TabNavigatorObserver getTabObserver(int tabIndex) {
    return _cachedObservers.putIfAbsent(
      tabIndex,
      () => TabNavigatorObserver(getTabName(tabIndex)),
    );
  }

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
      case tabDiscover:
        return 'Discover';
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

  /// Reset all 5 tab navigator stacks back to root (called on logout)
  void resetAllTabStacks() {
    for (final key in tabNavigatorKeys.values) {
      if (key.currentState != null && key.currentState!.canPop()) {
        key.currentState!.popUntil((route) => route.isFirst);
      }
    }
  }

  /// Navigate to nested screen inside active tab stack
  Future<T?>? pushNestedRoute<T>(int tabIndex, Widget page, {String? routeName}) {
    if (_isNavigatingFast()) return null;
    final key = tabNavigatorKeys[tabIndex];
    if (key?.currentState != null) {
      return key!.currentState!.push<T>(
        MaterialPageRoute(
          settings: RouteSettings(name: routeName ?? '${getTabName(tabIndex)}_${page.runtimeType}'),
          builder: (_) => page,
        ),
      );
    }
    return null;
  }

  /// Android & iOS System Back Button Handler for MainContainer Shell
  Future<bool> handleSystemBack(int currentTabIndex, Function(int) onSwitchToDefaultTab) async {
    final currentKey = tabNavigatorKeys[currentTabIndex];

    // 1. Check if the active tab's nested navigator can pop (pops attached BottomSheet or nested screen route)
    if (currentKey?.currentState != null && currentKey!.currentState!.canPop()) {
      currentKey.currentState!.pop();
      return false; // Handled back gesture
    }

    // 2. Check if the Root Navigator (Get.key) has an open dialog/overlay route
    final rootNav = Get.key.currentState;
    if (rootNav != null && rootNav.canPop()) {
      rootNav.pop();
      return false;
    }

    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true || Get.isOverlaysOpen == true) {
      CW.dismissBottomSheet();
      return false;
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
    resetAllTabStacks();
    Get.offAllNamed(Routes.AUTHENTICATION);
  }

  /// Central Deep Link Handler: Forwards to DeepLinkRouter
  void handleDeepLink(Uri uri, [Function(int)? onTabChange]) {
    DeepLinkRouter.routeUri(uri);
  }
}

/// NavigatorObserver for tab-nested routes to log pushes and pops
class TabNavigatorObserver extends NavigatorObserver {
  final String tabName;
  TabNavigatorObserver(this.tabName);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final routeName = route.settings.name ?? "${tabName}_Root";
    debugPrint("NAV PUSH: $routeName | CURRENT NAVIGATOR: ${tabName}Navigator | BOTTOM TAB: $tabName");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final routeName = route.settings.name ?? "${tabName}_Root";
    debugPrint("NAV POP: $routeName | CURRENT NAVIGATOR: ${tabName}Navigator | BOTTOM TAB: $tabName");
  }
}

