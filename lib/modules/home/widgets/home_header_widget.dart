// lib/modules/home/widgets/home_header_widget.dart
//
// Tuần 3: Hiển thị tên user thật + greeting theo giờ + ngày tháng thật.
// Streak vẫn mock — sẽ làm thật ở Tuần 8 (push notifications + settings).

import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _todayLabel() {
    return DateFormat('EEEE, MMM d').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
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
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                AppGap.h2,
                Text(
                  _todayLabel(),
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
                  '7-day streak',
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
