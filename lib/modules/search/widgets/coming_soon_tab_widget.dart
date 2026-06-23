import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class ComingSoonTabWidget extends StatelessWidget {
  const ComingSoonTabWidget({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: colors.textSecondary),
          AppGap.h16,
          Text(label, style: context.themed(AppTextStyles.h2)),
          AppGap.h8,
          Text(
            'search.coming_soon'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
