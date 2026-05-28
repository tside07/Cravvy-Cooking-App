import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class ComingSoonTabWidget extends StatelessWidget {
  const ComingSoonTabWidget({
    super.key,
    required this.icon,
    required this.label,
  });

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: AppTextStyles.s20.copyWith(fontSize: 52)),
          AppGap.h16,
          Text(label, style: Theme.of(context).textTheme.headlineSmall),
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
