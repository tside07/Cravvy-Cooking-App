import 'dart:async';

import 'package:cravvy_cooking_app/core/utils/recipe_cooking_steps.dart';
import 'package:cravvy_cooking_app/core/utils/recipe_steps_resolver.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

class CookingModeScreen extends StatefulWidget {
  const CookingModeScreen({super.key, required this.meal});

  final Meal meal;

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int _currentStep = 0;
  bool _timerRunning = false;
  int _timeRemaining = 0;
  Timer? _timer;

  bool _loadingSteps = true;
  List<CookingStep> _steps = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSteps());
  }

  Future<void> _loadSteps() async {
    RecipeProvider? lookup;
    try {
      lookup = context.read<RecipeProvider>();
    } catch (_) {
      lookup = null;
    }

    final lines = await RecipeStepsResolver.resolveLines(
      widget.meal,
      recipeLookup: lookup,
    );

    if (!mounted) return;
    setState(() {
      _steps = RecipeCookingSteps.fromStrings(lines);
      _loadingSteps = false;
      _currentStep = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      _timeRemaining = minutes * 60;
      _timerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeRemaining <= 0) {
        t.cancel();
        setState(() => _timerRunning = false);
      } else {
        setState(() => _timeRemaining--);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _timerRunning = false);
  }

  void _resetTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      _timeRemaining = minutes * 60;
      _timerRunning = false;
    });
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _timer?.cancel();
      setState(() {
        _currentStep++;
        _timerRunning = false;
        _timeRemaining = 0;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _timer?.cancel();
      setState(() {
        _currentStep--;
        _timerRunning = false;
        _timeRemaining = 0;
      });
    }
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final _ = context.locale;

    if (_loadingSteps) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      );
    }

    if (_steps.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'cooking_mode.no_steps'.tr(),
                      style: context.themed(
                        AppTextStyles.s16,
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('cooking_mode.exit'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final step = _steps[_currentStep];
    final progress = (_currentStep + 1) / _steps.length;
    final isLast = _currentStep == _steps.length - 1;
    final imageUrl = widget.meal.imageUrl.trim();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => _showExitDialog(context),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'cooking_mode.title'.tr(),
                          style: context.themed(
                            AppTextStyles.s14,
                            color: colors.textSecondary,
                          ),
                        ),
                        Text(
                          widget.meal.name,
                          style: context.themed(
                            AppTextStyles.h2.copyWith(fontSize: 17),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppBorderRadius.chip,
                    ),
                    child: Text(
                      '${_currentStep + 1}/${_steps.length}',
                      style: AppTextStyles.s12.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(AppRadius.c4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: colors.elevated,
                  color: AppColors.primary,
                  minHeight: 6,
                ),
              ),
            ),
            if (imageUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: widget.meal.type.lightColor,
                        child: Center(
                          child: Icon(
                            widget.meal.type.icon,
                            color: widget.meal.type.color,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.e2Of(
                          Theme.of(context).brightness,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${step.number}',
                          style: AppTextStyles.display.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: context.cardBox(radius: 16),
                          child: Text(
                            step.text,
                            style: context.themed(AppTextStyles.s16).copyWith(
                              height: 1.7,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    if (step.timerMinutes != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.cardSurface,
                          borderRadius: AppBorderRadius.card,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                          boxShadow: AppShadows.e1Of(
                            Theme.of(context).brightness,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'cooking_mode.timer_label'.tr(
                                    namedArgs: {
                                      'min': '${step.timerMinutes}',
                                    },
                                  ),
                                  style: AppTextStyles.s14.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _timeRemaining > 0
                                  ? _formatTime(_timeRemaining)
                                  : '${step.timerMinutes!.toString().padLeft(2, '0')}:00',
                              style: context.themed(
                                AppTextStyles.display.copyWith(
                                  fontSize: 40,
                                  letterSpacing: 2,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _TimerButton(
                                  icon: Icons.replay_rounded,
                                  onTap: () =>
                                      _resetTimer(step.timerMinutes!),
                                ),
                                const SizedBox(width: 12),
                                Pressable(
                                  onTap: _timerRunning
                                      ? _pauseTimer
                                      : () =>
                                          _startTimer(step.timerMinutes!),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: AppShadows.e2Of(
                                        Theme.of(context).brightness,
                                      ),
                                    ),
                                    child: Icon(
                                      _timerRunning
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _prevStep,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                        ),
                        label: Text('cooking_mode.previous'.tr()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.borderDivider),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppBorderRadius.button,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: isLast
                          ? () => context.go(AppRouter.app)
                          : _nextStep,
                      icon: Icon(
                        isLast
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 16,
                      ),
                      label: Text(
                        isLast
                            ? 'cooking_mode.finish'.tr()
                            : 'cooking_mode.next_step'.tr(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.button,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.sheet),
        title: Text('cooking_mode.exit_title'.tr()),
        content: Text('cooking_mode.exit_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cooking_mode.stay'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('cooking_mode.exit'.tr()),
          ),
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.elevated,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colors.textSecondary, size: 20),
      ),
    );
  }
}
