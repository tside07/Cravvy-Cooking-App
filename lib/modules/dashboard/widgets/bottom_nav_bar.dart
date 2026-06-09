import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';



class _NavTab {

  final IconData icon;

  final String label;

  const _NavTab({required this.icon, required this.label});

}



List<_NavTab> _tabs(BuildContext context) => [
      _NavTab(icon: Icons.home_rounded, label: 'nav.home'.tr()),
      _NavTab(icon: Icons.calendar_month_rounded, label: 'nav.plan'.tr()),
      _NavTab(icon: Icons.search_rounded, label: 'nav.search'.tr()),
      _NavTab(icon: Icons.bar_chart_rounded, label: 'nav.progress'.tr()),
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

    final appColors = context.appColors;



    return Container(

      decoration: BoxDecoration(

        color: appColors.backgroundMain,

      ),

      child: SafeArea(

        top: false,

        child: SizedBox(

          height: 64,

          child: Row(

            children: List.generate(

              _tabs(context).length,

              (i) => _NavItem(

                tab: _tabs(context)[i],

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

    final appColors = context.appColors;

    final activeColor = appColors.iconActive;

    final inactiveColor = appColors.iconInactive;



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

                color: isSelected

                    ? appColors.navSelectedHighlight

                    : Colors.transparent,

                borderRadius: AppBorderRadius.a20,

              ),

              child: Icon(

                tab.icon,

                size: 22,

                color: isSelected ? activeColor : inactiveColor,

              ),

            ),

            AppGap.h2,

            AnimatedDefaultTextStyle(

              duration: const Duration(milliseconds: 220),

              style: TextStyle(

                fontFamily: 'Inter',

                fontSize: 10,

                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,

                color: isSelected ? activeColor : inactiveColor,

              ),

              child: Text(tab.label),

            ),

          ],

        ),

      ),

    );

  }

}


