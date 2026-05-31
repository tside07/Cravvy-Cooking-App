import 'package:cravvy_cooking_app/core/utils/recipe_steps_resolver.dart';
import 'package:cravvy_cooking_app/data/providers/recipe_provider.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/models/meal.dart';
import 'package:easy_localization/easy_localization.dart';

/// Instructions tab — steps from Supabase (`recipes.steps`).
class MealDetailInstructionsWidget extends StatefulWidget {
  const MealDetailInstructionsWidget({super.key, required this.meal});

  final Meal meal;

  @override
  State<MealDetailInstructionsWidget> createState() =>
      _MealDetailInstructionsWidgetState();
}

class _MealDetailInstructionsWidgetState
    extends State<MealDetailInstructionsWidget> {
  List<String> _steps = [];
  bool _loading = true;

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
      _steps = lines;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;

    if (_loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_steps.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Text(
            'cooking_mode.no_steps'.tr(),
            style: AppTextStyles.s14.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ...[
            for (var i = 0; i < _steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _StepCard(step: i + 1, text: _steps[i]),
              ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  AppRouter.cookingMode,
                  extra: widget.meal,
                ),
                icon: const Icon(Icons.restaurant_rounded),
                label: Text('cooking_mode.start_btn'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.a16,
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.text});

  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPad.a16,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a16,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: AppTextStyles.s14.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: AppTextStyles.s14.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
