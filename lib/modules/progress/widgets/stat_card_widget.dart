import 'package:cravvy_cooking_app/init.dart';

class StatCardWidget extends StatelessWidget {
  const StatCardWidget({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 10,
        ), //TODO: no AppPad equivalent for h10v14
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppBorderRadius.a16,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            AppGap.h4,
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
