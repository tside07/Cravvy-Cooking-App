import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/meal.dart';
import '../../meal_plan/provider/meal_plan_provider.dart';
import 'meal_swap_sheet.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            _WeekStrip(),
            _CalorieSummary(),
            const Expanded(child: _MealList()),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Meal Plan',
                  style: Theme.of(context).textTheme.headlineLarge),
              Text('Stay on track this week',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '7-day streak',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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

// ─── Week Strip ───────────────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  static const _days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        return Container(
          height: 90,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: List.generate(7, (i) {
              final plan = provider.weekPlan[i];
              final isSelected = provider.selectedDayIndex == i;
              final isToday = i == DateTime.now().weekday - 1;
              final hasAll = plan.isComplete;
              final hasSome = plan.loggedCount > 0;

              return Expanded(
                child: GestureDetector(
                  onTap: () => provider.selectDay(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                                ? AppColors.primary.withOpacity(0.4)
                                : AppColors.border,
                        width: isToday && !isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _days[i],
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d').format(plan.date),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Dot indicator
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasAll
                                ? AppColors.success
                                : hasSome
                                    ? AppColors.warning
                                    : isSelected
                                        ? Colors.white.withOpacity(0.4)
                                        : AppColors.border,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ─── Calorie Summary ──────────────────────────────────────────────────────────
class _CalorieSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final day = provider.selectedDay;
        final remaining = provider.remainingCalories;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Main calorie row
              Row(
                children: [
                  _CalStat(
                    label: 'Consumed',
                    value: '${day.totalCalories}',
                    unit: 'kcal',
                    color: Colors.white,
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        '${remaining > 0 ? remaining : 0}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Text(
                        'kcal left',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _CalStat(
                    label: 'Goal',
                    value: '${provider.targetCalories}',
                    unit: 'kcal',
                    color: Colors.white,
                    alignRight: true,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: provider.calorieProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              // Macros row
              Row(
                children: [
                  _MacroChip(
                    label: 'Protein',
                    value: '${day.totalProtein}g',
                    target: '${provider.targetProtein}g',
                    progress: provider.proteinProgress,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  _MacroChip(
                    label: 'Carbs',
                    value: '${day.totalCarbs}g',
                    target: '${provider.targetCarbs}g',
                    progress: provider.carbsProgress,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  _MacroChip(
                    label: 'Fat',
                    value: '${day.totalFat}g',
                    target: '${provider.targetFat}g',
                    progress: provider.fatProgress,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CalStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool alignRight;

  const _CalStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final String target;
  final double progress;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.target,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '/ $target',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 9,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Meal List ────────────────────────────────────────────────────────────────
class _MealList extends StatelessWidget {
  const _MealList();

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final meals = provider.selectedDay.meals;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: meals.length,
          itemBuilder: (context, i) => _MealCard(
            meal: meals[i],
            onToggle: () => provider.toggleMealLogged(meals[i].id),
            onSwap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ChangeNotifierProvider.value(
                value: provider,
                child: MealSwapSheet(meal: meals[i]),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onToggle;
  final VoidCallback onSwap;

  const _MealCard({
    required this.meal,
    required this.onToggle,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: meal.isLogged
              ? AppColors.success.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Meal type header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: meal.type.lightColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(meal.type.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  meal.type.label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: meal.type.color,
                  ),
                ),
                const Spacer(),
                // Swap button
                GestureDetector(
                  onTap: onSwap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz_rounded,
                            size: 14, color: meal.type.color),
                        const SizedBox(width: 4),
                        Text(
                          'Swap',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: meal.type.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Meal content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Meal image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    meal.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: meal.type.lightColor,
                      child: Center(
                        child: Text(meal.type.emoji,
                            style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Meal info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _InfoChip(
                              icon: Icons.local_fire_department_rounded,
                              label: '${meal.calories} cal',
                              color: AppColors.primary),
                          const SizedBox(width: 8),
                          _InfoChip(
                              icon: Icons.timer_outlined,
                              label: '${meal.prepTime} min',
                              color: AppColors.textSecondary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Macro pills
                      Row(
                        children: [
                          _MacroPill('P ${meal.protein}g', AppColors.secondaryLight,
                              AppColors.secondaryDark),
                          const SizedBox(width: 4),
                          _MacroPill('C ${meal.carbs}g', const Color(0xFFFFFAE6),
                              AppColors.accentDark),
                          const SizedBox(width: 4),
                          _MacroPill('F ${meal.fat}g', AppColors.primaryLight,
                              AppColors.primaryDark),
                        ],
                      ),
                    ],
                  ),
                ),

                // Check button
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: meal.isLogged
                          ? AppColors.success
                          : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: meal.isLogged
                            ? AppColors.success
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: meal.isLogged ? Colors.white : AppColors.textHint,
                    ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color text;

  const _MacroPill(this.label, this.bg, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
