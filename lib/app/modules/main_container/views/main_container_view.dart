import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/calendar/views/calendar_view.dart';
import 'package:lala_ai/app/modules/home/views/home_view.dart';
import 'package:lala_ai/app/modules/main_container/controllers/main_container_controller.dart';
import 'package:lala_ai/app/modules/main_container/widgets/pixo_overlay_widget.dart';
import 'package:lala_ai/app/modules/discover/views/discover_view.dart';
import 'package:lala_ai/app/modules/studio/views/studio_view.dart';
import 'package:lala_ai/app/modules/trending/views/trending_view.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class MainContainerView extends GetView<MainContainerController> {
  const MainContainerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await controller.handleWillPop();
          if (shouldPop) {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: CC.background,
          body: Stack(
            children: [
              // Primary Independent Tab Navigators inside IndexedStack
              Obx(() => IndexedStack(
                index: controller.currentIndex.value,
                children: [
                  _buildTabNavigator(AppNavigationService.tabDashboard, const HomeView()),
                  _buildTabNavigator(AppNavigationService.tabStudio, const StudioView()),
                  _buildTabNavigator(AppNavigationService.tabTrends, const TrendingView()),
                  _buildTabNavigator(AppNavigationService.tabCalendar, const CalendarView()),
                  _buildTabNavigator(AppNavigationService.tabDiscover, const DiscoverView()),
                ],
              )),

              // Global Draggable Pixo Assistant Overlay Widget
              const PixoOverlayWidget(),
            ],
          ),
          bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: CC.surface,
              border: Border(
                top: BorderSide(
                  color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                  width: 0.8,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: CC.isDark ? CC.black.withValues(alpha: 0.5) : CC.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: CC.surface,
              selectedItemColor: CC.primary,
              unselectedItemColor: CC.textSecondary,
              selectedLabelStyle: TS.caption(fontWeight: FontWeight.w700).copyWith(fontSize: 10),
              unselectedLabelStyle: TS.caption(fontWeight: FontWeight.w500).copyWith(fontSize: 10),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined, size: 20),
                  activeIcon: Icon(Icons.dashboard_rounded, size: 20),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.movie_creation_outlined, size: 20),
                  activeIcon: Icon(Icons.movie_creation_rounded, size: 20),
                  label: "Studio",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.trending_up_rounded, size: 20),
                  activeIcon: Icon(Icons.trending_up_rounded, size: 20),
                  label: "Trends",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined, size: 20),
                  activeIcon: Icon(Icons.calendar_month_rounded, size: 20),
                  label: "Calendar",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined, size: 20),
                  activeIcon: Icon(Icons.explore_rounded, size: 20),
                  label: "Discover",
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  /// Builds an independent Navigator for a tab to maintain its own stack state
  Widget _buildTabNavigator(int tabIndex, Widget rootPage) {
    final navKey = controller.navigationService.getTabNavigatorKey(tabIndex);
    final tabName = controller.navigationService.getTabName(tabIndex);
    return Navigator(
      key: navKey,
      observers: [
        controller.navigationService.getTabObserver(tabIndex),
      ],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name ?? "/tab/$tabName"),
          builder: (_) => rootPage,
        );
      },
    );
  }
}
