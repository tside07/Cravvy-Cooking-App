import 'package:cravvy_cooking_app/init.dart';

class SimpleDialogWidget extends StatelessWidget {
  const SimpleDialogWidget({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.onConfirm,
    required this.isDestructive,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.a20),
        title: Text(
          title,
          style: context.themed(
            AppTextStyles.s16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          body,
          style: context.themed(
            AppTextStyles.s14,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.themed(
                AppTextStyles.s14,
                color: colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Text(
              confirmLabel,
              style: AppTextStyles.s14.copyWith(
                color: isDestructive ? AppColors.error : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
  }
}
