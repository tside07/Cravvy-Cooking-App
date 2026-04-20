import 'package:cravvy_cooking_app/init.dart';

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

  static const _features = [
    'Unlimited AI meal suggestions',
    'Advanced nutrition tracking',
    '1,000+ premium recipes',
    'Smart shopping lists',
    'Ad-free experience',
    'Priority support',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti dots
            ...List.generate(20, (i) {
              final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.success];
              return Positioned(
                left: (i * 47.3) % MediaQuery.of(context).size.width,
                top: (i * 71.1) % (MediaQuery.of(context).size.height * 0.4),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length].withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),

            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Animated icon
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 44),
                    ),
                  ),
                  const SizedBox(height: 28),

                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Text('🎉 Trial Started!',
                            style: AppTextStyles.s20.copyWith(fontWeight: FontWeight.w800, fontSize: 28), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text('Welcome to Cravvy Premium! Enjoy all features completely free for 14 days.',
                            style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary, height: 1.6), textAlign: TextAlign.center),
                        const SizedBox(height: 28),

                        // Features card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                                  const SizedBox(width: 8),
                                  Text("What's unlocked for you", style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ..._features.map((f) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
                                          child: const Icon(Icons.check_rounded, color: AppColors.success, size: 13),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(f, style: AppTextStyles.s14),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Expiry note
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.warning),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Trial ends in 14 days. Cancel anytime from Profile → Settings.',
                                    style: AppTextStyles.s12.copyWith(color: AppColors.warning, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () => context.go(AppRouter.app),
                            icon: const Icon(Icons.explore_outlined, size: 20),
                            label: const Text('Explore Premium Features'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              textStyle: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
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
