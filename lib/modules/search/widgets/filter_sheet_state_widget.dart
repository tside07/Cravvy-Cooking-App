import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/filter_option_widget.dart';

// ─── Filter bottom sheet ──────────────────────────────────────────────────────

class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.selectedMealType,
    required this.selectedMaxCal,
    required this.selectedDifficulty,
    required this.onApply,
    required this.onReset,
  });

  final String? selectedMealType;
  final int? selectedMaxCal;
  final String? selectedDifficulty;
  final Function(String?, int?, String?) onApply;
  final VoidCallback onReset;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _mealType;
  int? _maxCal;
  String? _difficulty;

  static const _mealTypes = [
    ('breakfast', 'Breakfast', '🌅'),
    ('lunch', 'Lunch', '☀️'),
    ('dinner', 'Dinner', '🌙'),
    ('snack', 'Snack', '🍎'),
  ];

  static const _calorieOptions = [
    (300, '< 300 cal'),
    (450, '< 450 cal'),
    (600, '< 600 cal'),
  ];

  static const _difficulties = [
    ('easy', 'Easy', '🟢'),
    ('medium', 'Medium', '🟡'),
    ('hard', 'Hard', '🔴'),
  ];

  @override
  void initState() {
    super.initState();
    _mealType = widget.selectedMealType;
    _maxCal = widget.selectedMaxCal;
    _difficulty = widget.selectedDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppGap.h20,

            Row(
              children: [
                Text(
                  'Filter Recipes',
                  style: AppTextStyles.s18.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Reset',
                    style: AppTextStyles.s14.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h16,

            // Meal type
            Text(
              'Meal Type',
              style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600),
            ),
            AppGap.h8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _mealTypes.map<Widget>((record) {
                final (type, label, emoji) = record;
                final selected = _mealType == type;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _mealType = selected ? null : type),
                  child: FilterOptionWidget(
                    label: '$emoji $label',
                    selected: selected,
                  ),
                );
              }).toList(),
            ),
            AppGap.h16,

            // Calories
            Text(
              'Max Calories',
              style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600),
            ),
            AppGap.h8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _calorieOptions.map<Widget>((record) {
                final (cal, label) = record;
                final selected = _maxCal == cal;
                return GestureDetector(
                  onTap: () => setState(() => _maxCal = selected ? null : cal),
                  child: FilterOptionWidget(label: label, selected: selected),
                );
              }).toList(),
            ),
            AppGap.h16,

            // Difficulty
            Text(
              'Difficulty',
              style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600),
            ),
            AppGap.h8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _difficulties.map<Widget>((record) {
                final (diff, label, dot) = record;
                final selected = _difficulty == diff;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _difficulty = selected ? null : diff),
                  child: FilterOptionWidget(
                    label: '$dot $label',
                    selected: selected,
                  ),
                );
              }).toList(),
            ),
            AppGap.h24,

            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_mealType, _maxCal, _difficulty);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: AppTextStyles.s16.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
