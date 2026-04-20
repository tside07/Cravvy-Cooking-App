import 'package:cravvy_cooking_app/init.dart';
import 'package:flutter/services.dart';
import 'package:cravvy_cooking_app/modules/home/screens/home_screen.dart';
import 'package:cravvy_cooking_app/modules/meal_plan/screens/meal_plan_screen.dart';
import 'package:cravvy_cooking_app/modules/search/screens/search_screen.dart';
import 'package:cravvy_cooking_app/modules/progress/screens/progress_screen.dart';
import 'package:cravvy_cooking_app/modules/profile/screen/profile_screen.dart';
import 'package:cravvy_cooking_app/modules/dashboard/widgets/bottom_nav_bar.dart';
import 'package:cravvy_cooking_app/modules/dashboard/provider/dashboard_tab_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    MealPlanScreen(),
    SearchScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for programmatic tab switches from child screens.
    final tabProvider = context.watch<DashboardTabProvider>();
    if (tabProvider.index != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _currentIndex = tabProvider.index);
      });
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          tabProvider.switchTo(i);
          _onTabTap(i);
        },
      ),
    );
  }
}
