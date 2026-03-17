import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../modules/meal_plan/screen/meal_plan_screen.dart';
import 'home/screen/home_screen.dart';
import '../modules/search/screen/search_screen.dart';
import '../modules/progress/screen/progress_screen.dart';
import '../modules/profile/screen/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded,        label: 'Home'),
    _TabItem(icon: Icons.calendar_month_rounded, label: 'Meal Plan'),
    _TabItem(icon: Icons.search_rounded,      label: 'Search'),
    _TabItem(icon: Icons.bar_chart_rounded,   label: 'Progress'),
    _TabItem(icon: Icons.person_rounded,      label: 'Profile'),
  ];

  final _screens = const [
    HomeScreen(),
    MealPlanScreen(),
    SearchScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        tabs: _tabs,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final isSelected = currentIndex == i;
              final tab = tabs[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          tab.icon,
                          size: 22,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
