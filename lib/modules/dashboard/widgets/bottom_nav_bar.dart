import 'package:cravvy_cooking_app/init.dart';

class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}

const _tabs = [
  _NavTab(icon: Icons.home_rounded, label: 'Home'),
  _NavTab(icon: Icons.calendar_month_rounded, label: 'Plan'),
  _NavTab(icon: Icons.search_rounded, label: 'Search'),
  _NavTab(icon: Icons.bar_chart_rounded, label: 'Progress'),
  _NavTab(icon: Icons.person_rounded, label: 'Profile'),
];

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
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
            color: Colors.black.withOpacity(
              0.06,
            ), // no AppColors equivalent for 0.06 opacity
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
            children: List.generate(
              _tabs.length,
              (i) => _NavItem(
                tab: _tabs[i],
                isSelected: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: AppPad.h12v4,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Colors.transparent,
                borderRadius: AppBorderRadius.a20,
              ),
              child: Icon(
                tab.icon,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
            AppGap.h2,
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}
