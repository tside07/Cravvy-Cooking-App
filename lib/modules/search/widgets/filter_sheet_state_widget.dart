import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/search/widgets/filter_option_widget.dart';
import 'package:easy_localization/easy_localization.dart';

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

  /// route key (value) — label được lấy từ .tr() để hiển thị
  static const _mealTypeKeys = [
    ('breakfast', 'search.filter.breakfast'),
    ('lunch', 'search.filter.lunch'),
    ('dinner', 'search.filter.dinner'),
    ('snack', 'search.filter.snack'),
  ];

  static const _calorieOptions = [
    (300, 'search.filter.cal_300'),
    (450, 'search.filter.cal_450'),
    (600, 'search.filter.cal_600'),
  ];

  static const _difficultyKeys = [
    ('easy', 'search.filter.easy'),
    ('medium', 'search.filter.medium'),
    ('hard', 'search.filter.hard'),
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
                  borderRadius: AppBorderRadius.a2,
                ),
              ),
            ),
            AppGap.h20,

            Row(
              children: [
                Text(
                  'search.filter.title'.tr(),
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
                    'search.filter.reset'.tr(),
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
              'search.filter.meal_type'.tr(),
              style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600),
            ),
            AppGap.h8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _mealTypeKeys.map<Widget>((record) {
                final (key, labelKey) = record;
                final selected = _mealType == key;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _mealType = selected ? null : key),
                  child: FilterOptionWidget(
                    label: labelKey.tr(),
                    selected: selected,
                  ),
                );
              }).toList(),
            ),
            AppGap.h16,

            // Max calories
            Text(
              'search.filter.max_calories'.tr(),
              style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600),
            ),
            AppGap.h8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _calorieOptions.map<Widget>((record) {
                final (cal, labelKey) = record;
                final selected = _maxCal == cal;
                return GestureDetector(
                  onTap: () => setState(() => _maxCal = selected ? null : cal),
                  child: FilterOptionWidget(
                    label: labelKey.tr(),
                    selected: selected,
                  ),
                );
              }).toList(),
            ),
            AppGap.h16,

            // Difficulty
            Text(
              'search.filter.difficulty'.tr(),
              style: AppTextStyles.s14.copyWith(fontWeight: FontWeight.w600),
            ),
            AppGap.h8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _difficultyKeys.map<Widget>((record) {
                final (key, labelKey) = record;
                final selected = _difficulty == key;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _difficulty = selected ? null : key),
                  child: FilterOptionWidget(
                    label: labelKey.tr(),
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
                  padding: AppPad.v14,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.a14,
                  ),
                ),
                child: Text(
                  'search.filter.apply'.tr(),
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
