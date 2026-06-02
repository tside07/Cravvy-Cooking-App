import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'home.greeting_morning'.tr();
    if (hour < 17) return 'home.greeting_afternoon'.tr();
    return 'home.greeting_evening'.tr();
  }

  String _todayLabel(BuildContext context) {
    return DateFormat(
      'EEEE, MMM d',
      context.locale.toString(),
    ).format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    final user = context.watch<AuthProvider>().user;
    final firstName = user?.fullName?.split(' ').first ?? 'there';

    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 20, right: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $firstName! 👋',
                  style: AppTextStyles.s20.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppGap.h2,
                Text(
                  _todayLabel(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Streak badge — mock, sẽ làm thật Tuần 8
          Container(
            padding: AppPad.h12v6,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppBorderRadius.a20,
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                AppGap.w4,
                Text(
                  'home.streak_badge'.tr(namedArgs: {'n': '7'}),
                  style: AppTextStyles.s12.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
