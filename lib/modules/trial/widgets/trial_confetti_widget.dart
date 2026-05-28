import 'package:cravvy_cooking_app/init.dart';

class TrialConfettiWidget extends StatelessWidget {
  const TrialConfettiWidget({super.key, required this.fadeAnim});

  final Animation<double> fadeAnim;

  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.success,
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: List.generate(20, (i) {
        return Positioned(
          left: (i * 47.3) % size.width,
          top: (i * 71.1) % (size.height * 0.4),
          child: FadeTransition(
            opacity: fadeAnim,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _colors[i % _colors.length].withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
