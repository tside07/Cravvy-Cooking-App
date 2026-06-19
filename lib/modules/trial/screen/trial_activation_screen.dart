import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/trial/widgets/trial_confetti_widget.dart';
import 'package:cravvy_cooking_app/modules/trial/widgets/trial_cta_button_widget.dart';
import 'package:cravvy_cooking_app/modules/trial/widgets/trial_expiry_note_widget.dart';
import 'package:cravvy_cooking_app/modules/trial/widgets/trial_hero_widget.dart';
import 'package:cravvy_cooking_app/modules/trial/widgets/trial_unlocked_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class TrialActivationScreen extends StatefulWidget {
  const TrialActivationScreen({super.key});

  @override
  State<TrialActivationScreen> createState() => _TrialActivationScreenState();
}

class _TrialActivationScreenState extends State<TrialActivationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  // Build tại runtime để .tr() đúng ngôn ngữ
  static List<String> _features() => [
    'trial.feat_1'.tr(),
    'trial.feat_2'.tr(),
    'trial.feat_3'.tr(),
    'trial.feat_4'.tr(),
    'trial.feat_5'.tr(),
    'trial.feat_6'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ── Background confetti ───────────────────────────────────────
            TrialConfettiWidget(fadeAnim: _fadeAnim),

            // ── Main content ──────────────────────────────────────────────
            SingleChildScrollView(
              padding: AppPad.h24,
              child: Column(
                children: [
                  AppGap.h60,

                  TrialHeroWidget(scaleAnim: _scaleAnim, fadeAnim: _fadeAnim),
                  AppGap.h28,

                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        TrialUnlockedCardWidget(features: _features()),
                        AppGap.h28,

                        const TrialExpiryNoteWidget(),
                        AppGap.h28,

                        TrialCtaButtonWidget(
                          onPressed: () => context.go(AppRouter.app),
                        ),
                        AppGap.h40,
                      ],
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
}
