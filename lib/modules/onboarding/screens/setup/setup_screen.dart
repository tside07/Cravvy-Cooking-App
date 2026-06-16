import 'package:cravvy_cooking_app/core/theme/pre_auth_theme.dart';
import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_progress_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_select_chip_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_input_label_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_sub_header_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_num_field_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_continue_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';

String _genderLabel(String gender) => switch (gender) {
  'Male' => 'onboarding_setup.male'.tr(),
  'Female' => 'onboarding_setup.female'.tr(),
  'Other' => 'onboarding_setup.other'.tr(),
  _ => gender,
};

String _dietLabel(String diet) => switch (diet) {
  'Eat Clean' => 'onboarding_setup.diet_eat_clean'.tr(),
  'Low-Carb' => 'onboarding_setup.diet_low_carb'.tr(),
  'Keto' => 'onboarding_setup.diet_keto'.tr(),
  'Intermittent Fasting' => 'onboarding_setup.diet_intermittent_fasting'.tr(),
  'Vegetarian' => 'onboarding_setup.diet_vegetarian'.tr(),
  'Vegan' => 'onboarding_setup.diet_vegan'.tr(),
  'High-Protein' => 'onboarding_setup.diet_high_protein'.tr(),
  'Low-Sugar' => 'onboarding_setup.diet_low_sugar'.tr(),
  'Gluten-Free' => 'onboarding_setup.diet_gluten_free'.tr(),
  'No Specific Diet' => 'onboarding_setup.diet_no_specific'.tr(),
  _ => diet,
};

String _allergyLabel(String item) => switch (item) {
  'Peanuts' => 'onboarding_setup.allergy_peanuts'.tr(),
  'Shellfish' => 'onboarding_setup.allergy_shellfish'.tr(),
  'Dairy' => 'onboarding_setup.allergy_dairy'.tr(),
  'Gluten' => 'onboarding_setup.allergy_gluten'.tr(),
  'Eggs' => 'onboarding_setup.allergy_eggs'.tr(),
  'Soy' => 'onboarding_setup.allergy_soy'.tr(),
  'Tree Nuts' => 'onboarding_setup.allergy_tree_nuts'.tr(),
  'Fish' => 'onboarding_setup.allergy_fish'.tr(),
  _ => item,
};

String _prefLabel(String item) => switch (item) {
  'No Pork' => 'onboarding_setup.pref_no_pork'.tr(),
  'No Beef' => 'onboarding_setup.pref_no_beef'.tr(),
  'No Seafood' => 'onboarding_setup.pref_no_seafood'.tr(),
  'No Spicy' => 'onboarding_setup.pref_no_spicy'.tr(),
  'No Raw Foods' => 'onboarding_setup.pref_no_raw_foods'.tr(),
  _ => item,
};

String _avoidLabel(String item) {
  final allergy = _allergyLabel(item);
  if (allergy != item) return allergy;
  return _prefLabel(item);
}

String _bmiCategoryLabel(double? bmi) {
  if (bmi == null) return '';
  if (bmi < 18.5) return 'onboarding_setup.bmi_underweight'.tr();
  if (bmi < 25) return 'onboarding_setup.bmi_normal'.tr();
  if (bmi < 30) return 'onboarding_setup.bmi_overweight'.tr();
  return 'onboarding_setup.bmi_obese'.tr();
}

String _cookingTimeLabel(String id) => switch (id) {
  'quick' => 'setup_complete.time_quick'.tr(),
  'short' => 'setup_complete.time_short'.tr(),
  'medium' => 'setup_complete.time_medium'.tr(),
  'long' => 'setup_complete.time_long'.tr(),
  _ => 'setup_complete.time_flexible'.tr(),
};

String _skillLabel(String id) => switch (id) {
  'beginner' => 'onboarding_setup.skill_beginner'.tr(),
  'intermediate' => 'onboarding_setup.skill_intermediate'.tr(),
  'advanced' => 'onboarding_setup.skill_advanced'.tr(),
  _ => id,
};

String _skillDesc(String id) => switch (id) {
  'beginner' => 'onboarding_setup.skill_beginner_desc'.tr(),
  'intermediate' => 'onboarding_setup.skill_intermediate_desc'.tr(),
  'advanced' => 'onboarding_setup.skill_advanced_desc'.tr(),
  _ => id,
};

// TODO: Helper: bọc body để fix infinite width trên cả web lẫn mobile
// Mọi setup screen đều dùng cái này thay vì Scaffold trực tiếp
class _SetupShell extends StatelessWidget {
  const _SetupShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PreAuthScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SizedBox(width: constraints.maxWidth, child: child),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1: Thông tin cơ bản
// ─────────────────────────────────────────────────────────────────────────────
class SetupStep1Screen extends StatefulWidget {
  const SetupStep1Screen({super.key});

  @override
  State<SetupStep1Screen> createState() => _SetupStep1ScreenState();
}

class _SetupStep1ScreenState extends State<SetupStep1Screen> {
  final _ageCtrl = TextEditingController(text: '25');
  final _heightCtrl = TextEditingController(text: '170');
  final _weightCtrl = TextEditingController(text: '70');
  String _gender = 'Male';
  bool _isLoading = false;

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  double? get _bmi {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    if (h == null || w == null || h == 0) return null;
    return w / ((h / 100) * (h / 100));
  }

  String get _bmiCategory => _bmiCategoryLabel(_bmi);

  Color _bmiColor(AppColorExtension colors) {
    final b = _bmi;
    if (b == null) return colors.textSecondary;
    if (b < 18.5) return AppColors.warning;
    if (b < 25) return AppColors.success;
    if (b < 30) return AppColors.warning;
    return AppColors.error;
  }

  Future<void> _continue() async {
    final age = int.tryParse(_ageCtrl.text);
    final height = double.tryParse(_heightCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);

    if (age == null || height == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('onboarding_setup.val_incomplete'.tr())),
      );
      return;
    }

    setState(() => _isLoading = true);
    await context.read<AuthProvider>().updateProfileBasicInfo(
      age: age,
      gender: _gender,
      heightCm: height,
      weightKg: weight,
    );
    setState(() => _isLoading = false);
    if (mounted) context.push(AppRouter.setupStep2);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _SetupShell(
      child: Column(
        children: [
          const SetupProgressWidget(current: 1, total: 5),
          Expanded(
            child: LayoutBuilder(
              builder: (_, constraints) => SingleChildScrollView(
                padding: AppPad.h24,
                child: ConstrainedBox(
                  // KEY FIX: đảm bảo Column con có width = maxWidth của parent
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppGap.h8,
                      Text(
                        'onboarding_setup.personalize'.tr(),
                        style: AppTextStyles.s20.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          color: colors.textPrimary,
                        ),
                      ),
                      AppGap.h8,
                      Text(
                        'onboarding_setup.personalize_desc'.tr(),
                        style: AppTextStyles.s14.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      AppGap.h28,

                      SetupInputLabelWidget('onboarding_setup.age'.tr()),
                      AppGap.h8,
                      SetupNumFieldWidget(
                        controller: _ageCtrl,
                        hint: 'onboarding_setup.hint_age'.tr(),
                        onChanged: (_) => setState(() {}),
                      ),
                      AppGap.h20,

                      SetupInputLabelWidget('onboarding_setup.gender'.tr()),
                      AppGap.h8,
                      Row(
                        children: ['Male', 'Female', 'Other']
                            .map(
                              (g) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: g != 'Other' ? 8 : 0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _gender = g),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: _gender == g
                                            ? AppColors.primary
                                            : const Color(0xFF2A3A44),
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: _gender == g
                                              ? AppColors.primary
                                              : colors.textSecondary.withValues(
                                                  alpha: 0.35,
                                                ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _genderLabel(g),
                                          style: AppTextStyles.s14.copyWith(
                                            color: _gender == g
                                                ? Colors.white
                                                : colors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      AppGap.h20,

                      SetupInputLabelWidget('onboarding_setup.height'.tr()),
                      AppGap.h8,
                      SetupNumFieldWidget(
                        controller: _heightCtrl,
                        hint: 'onboarding_setup.hint_height'.tr(),
                        onChanged: (_) => setState(() {}),
                      ),
                      AppGap.h20,

                      SetupInputLabelWidget('onboarding_setup.weight'.tr()),
                      AppGap.h8,
                      SetupNumFieldWidget(
                        controller: _weightCtrl,
                        hint: 'onboarding_setup.hint_weight'.tr(),
                        onChanged: (_) => setState(() {}),
                      ),
                      AppGap.h20,

                      if (_bmi != null)
                        Container(
                          padding: AppPad.a16,
                          decoration: BoxDecoration(
                            color: colors.cardSurface,
                            borderRadius: AppBorderRadius.card,
                            border: Border.all(color: colors.borderDivider),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'onboarding_setup.bmi'.tr(),
                                      style: AppTextStyles.s12.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                    AppGap.h4,
                                    Text(
                                      _bmi!.toStringAsFixed(1),
                                      style: context.themed(
                                        AppTextStyles.display.copyWith(
                                          fontSize: 28,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: AppPad.h12,
                                decoration: BoxDecoration(
                                  color: _bmiColor(
                                    colors,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: AppBorderRadius.chip,
                                ),
                                child: Text(
                                  _bmiCategory,
                                  style: AppTextStyles.s14.copyWith(
                                    color: _bmiColor(colors),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      AppGap.h24,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SetupContinueButtonWidget(
            onPressed: _isLoading ? null : _continue,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2: Mục tiêu
// ─────────────────────────────────────────────────────────────────────────────
class SetupStep2Screen extends StatefulWidget {
  const SetupStep2Screen({super.key});

  @override
  State<SetupStep2Screen> createState() => _SetupStep2ScreenState();
}

class _SetupStep2ScreenState extends State<SetupStep2Screen> {
  String _selectedGoal = 'lose-weight';
  bool _isLoading = false;

  static const _goals = [
    {
      'id': 'lose-weight',
      'titleKey': 'onboarding_setup.goal_lose_weight',
      'descKey': 'onboarding_setup.goal_lose_weight_desc',
      'icon': Icons.local_fire_department_rounded,
      'color': 0xFFEF4444,
    },
    {
      'id': 'build-muscle',
      'titleKey': 'onboarding_setup.goal_build_muscle',
      'descKey': 'onboarding_setup.goal_build_muscle_desc',
      'icon': Icons.fitness_center_rounded,
      'color': 0xFF3B82F6,
    },
    {
      'id': 'maintain',
      'titleKey': 'onboarding_setup.goal_maintain',
      'descKey': 'onboarding_setup.goal_maintain_desc',
      'icon': Icons.balance_rounded,
      'color': 0xFF6A8A42,
    },
    {
      'id': 'health',
      'titleKey': 'onboarding_setup.goal_health',
      'descKey': 'onboarding_setup.goal_health_desc',
      'icon': Icons.favorite_rounded,
      'color': 0xFF8B5CF6,
    },
  ];

  Future<void> _continue() async {
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().updateSetupData(goal: _selectedGoal);
    setState(() => _isLoading = false);
    if (mounted) context.push(AppRouter.setupStep3);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _SetupShell(
      child: Column(
        children: [
          const SetupProgressWidget(current: 2, total: 5),
          Expanded(
            child: Padding(
              padding: AppPad.h24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppGap.h8,
                  Text(
                    'onboarding_setup.main_goal'.tr(),
                    style: AppTextStyles.s20.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: colors.textPrimary,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    'onboarding_setup.main_goal_desc'.tr(),
                    style: AppTextStyles.s14.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  AppGap.h28,
                  // GridView trong Expanded + crossAxisAlignment.stretch → bounded
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                      children: _goals.map((g) {
                        final isSelected = _selectedGoal == g['id'] as String;
                        final color = Color(g['color'] as int);
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGoal = g['id'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : colors.cardSurface,
                              borderRadius: AppBorderRadius.a20,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : color.withValues(alpha: 0.12),
                                    borderRadius: AppBorderRadius.a14,
                                  ),
                                  child: Icon(
                                    g['icon'] as IconData,
                                    color: isSelected ? Colors.white : color,
                                    size: 24,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  (g['titleKey'] as String).tr(),
                                  style: AppTextStyles.s14.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppColors.primary
                                        : colors.textPrimary,
                                  ),
                                ),
                                AppGap.h4,
                                Text(
                                  (g['descKey'] as String).tr(),
                                  style: AppTextStyles.s12.copyWith(
                                    color: isSelected
                                        ? AppColors.primary.withValues(
                                            alpha: 0.75,
                                          )
                                        : colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  AppGap.h16,
                ],
              ),
            ),
          ),
          SetupContinueButtonWidget(
            onPressed: _isLoading ? null : _continue,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3: Chế độ ăn
// ─────────────────────────────────────────────────────────────────────────────
class SetupStep3Screen extends StatefulWidget {
  const SetupStep3Screen({super.key});

  @override
  State<SetupStep3Screen> createState() => _SetupStep3ScreenState();
}

class _SetupStep3ScreenState extends State<SetupStep3Screen> {
  final Set<String> _selected = {};
  bool _isLoading = false;

  static const _diets = [
    'Eat Clean',
    'Low-Carb',
    'Keto',
    'Intermittent Fasting',
    'Vegetarian',
    'Vegan',
    'High-Protein',
    'Low-Sugar',
    'Gluten-Free',
    'No Specific Diet',
  ];

  void _toggle(String diet) {
    setState(() {
      if (diet == 'No Specific Diet') {
        _selected.clear();
        _selected.add(diet);
      } else {
        _selected.remove('No Specific Diet');
        _selected.contains(diet) ? _selected.remove(diet) : _selected.add(diet);
      }
    });
  }

  Future<void> _continue() async {
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().updateSetupData(
      diets: _selected.toList(),
    );
    setState(() => _isLoading = false);
    if (mounted) context.push(AppRouter.setupStep4);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _SetupShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SetupProgressWidget(current: 3, total: 5),
          Expanded(
            child: Padding(
              padding: AppPad.h24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppGap.h8,
                  Text(
                    'onboarding_setup.follow_diet'.tr(),
                    style: AppTextStyles.s20.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: colors.textPrimary,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    'onboarding_setup.select_diet'.tr(),
                    style: AppTextStyles.s14.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  AppGap.h24,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: _diets
                            .map(
                              (d) => SetupSelectChipWidget(
                                label: _dietLabel(d),
                                selected: _selected.contains(d),
                                onTap: () => _toggle(d),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SetupContinueButtonWidget(
            onPressed: _isLoading ? null : _continue,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4: Thực phẩm cần tránh
// ─────────────────────────────────────────────────────────────────────────────
class SetupStep4Screen extends StatefulWidget {
  const SetupStep4Screen({super.key});

  @override
  State<SetupStep4Screen> createState() => _SetupStep4ScreenState();
}

class _SetupStep4ScreenState extends State<SetupStep4Screen> {
  final Set<String> _selected = {};
  bool _noRestrictions = false;
  bool _isLoading = false;
  final _customCtrl = TextEditingController();

  static const _allergies = [
    'Peanuts',
    'Shellfish',
    'Dairy',
    'Gluten',
    'Eggs',
    'Soy',
    'Tree Nuts',
    'Fish',
  ];
  static const _prefs = [
    'No Pork',
    'No Beef',
    'No Seafood',
    'No Spicy',
    'No Raw Foods',
  ];

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _toggle(String item) {
    setState(() {
      _noRestrictions = false;
      _selected.contains(item) ? _selected.remove(item) : _selected.add(item);
    });
  }

  void _addCustom() {
    final v = _customCtrl.text.trim();
    if (v.isNotEmpty) {
      setState(() {
        _selected.add(v);
        _noRestrictions = false;
      });
      _customCtrl.clear();
    }
  }

  Future<void> _continue() async {
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().updateSetupData(
      avoidFoods: _noRestrictions ? [] : _selected.toList(),
    );
    setState(() => _isLoading = false);
    if (mounted) context.push(AppRouter.setupStep5);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _SetupShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SetupProgressWidget(current: 4, total: 5),
          Expanded(
            child: Padding(
              padding: AppPad.h24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppGap.h8,
                  Text(
                    'onboarding_setup.restrictions'.tr(),
                    style: AppTextStyles.s20.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: colors.textPrimary,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    'onboarding_setup.restrictions_desc'.tr(),
                    style: AppTextStyles.s14.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  AppGap.h24,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SetupSubHeaderWidget(
                            'onboarding_setup.section_allergies'.tr(),
                          ),
                          AppGap.h10,
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: _allergies
                                .map(
                                  (a) => SetupSelectChipWidget(
                                    label: _allergyLabel(a),
                                    selected: _selected.contains(a),
                                    onTap: () => _toggle(a),
                                  ),
                                )
                                .toList(),
                          ),
                          AppGap.h20,
                          SetupSubHeaderWidget(
                            'onboarding_setup.section_preferences'.tr(),
                          ),
                          AppGap.h10,
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: _prefs
                                .map(
                                  (p) => SetupSelectChipWidget(
                                    label: _prefLabel(p),
                                    selected: _selected.contains(p),
                                    onTap: () => _toggle(p),
                                  ),
                                )
                                .toList(),
                          ),
                          AppGap.h20,
                          SetupSubHeaderWidget(
                            'onboarding_setup.section_add_custom'.tr(),
                          ),
                          AppGap.h10,
                          // KEY FIX: Row cần parent có bounded width
                          // crossAxisAlignment.stretch trên Column cha đảm bảo điều này
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _customCtrl,
                                  style: AppTextStyles.s14.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                  cursorColor: colors.textPrimary,
                                  decoration: InputDecoration(
                                    hintText:
                                        'onboarding_setup.hint_restrictions'
                                            .tr(),
                                    hintStyle: AppTextStyles.s14.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF2A3A44),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: colors.textSecondary.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              AppGap.w10,
                              // KEY FIX: ElevatedButton bị infinite width khi không bounded
                              // SizedBox với width cố định giải quyết vấn đề này
                              SizedBox(
                                width: 52,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _addCustom,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppBorderRadius.a12,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_selected.isNotEmpty) ...[
                            AppGap.h16,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selected
                                  .map(
                                    (s) => Chip(
                                      label: Text(
                                        _avoidLabel(s),
                                        style: AppTextStyles.s12.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      backgroundColor: AppColors.primaryLight,
                                      deleteIcon: const Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      onDeleted: () =>
                                          setState(() => _selected.remove(s)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppBorderRadius.a20,
                                        side: const BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          AppGap.h20,
                          GestureDetector(
                            onTap: () => setState(() {
                              _noRestrictions = !_noRestrictions;
                              if (_noRestrictions) _selected.clear();
                            }),
                            child: Container(
                              padding: AppPad.a14,
                              decoration: BoxDecoration(
                                color: _noRestrictions
                                    ? AppColors.primaryLight
                                    : colors.cardSurface,
                                borderRadius: AppBorderRadius.a14,
                                border: Border.all(
                                  color: _noRestrictions
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _noRestrictions
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: _noRestrictions
                                        ? AppColors.primary
                                        : colors.textDisabled,
                                  ),
                                  AppGap.w10,
                                  Expanded(
                                    child: Text(
                                      'onboarding_setup.no_restrictions'.tr(),
                                      style: AppTextStyles.s14.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _noRestrictions
                                            ? AppColors.primary
                                            : colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppGap.h24,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SetupContinueButtonWidget(
            onPressed: _isLoading ? null : _continue,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 5: Thời gian nấu + kỹ năng
// ─────────────────────────────────────────────────────────────────────────────
class SetupStep5Screen extends StatefulWidget {
  const SetupStep5Screen({super.key});

  @override
  State<SetupStep5Screen> createState() => _SetupStep5ScreenState();
}

class _SetupStep5ScreenState extends State<SetupStep5Screen> {
  String _cookingTime = 'short';
  String _skillLevel = 'intermediate';
  bool _isLoading = false;

  static const _times = [
    {'id': 'quick', 'icon': Icons.bolt_rounded},
    {'id': 'short', 'icon': Icons.schedule_rounded},
    {'id': 'medium', 'icon': Icons.timer_outlined},
    {'id': 'long', 'icon': Icons.restaurant_menu_rounded},
  ];

  static const _skills = [
    {'id': 'beginner', 'emoji': '🥚'},
    {'id': 'intermediate', 'emoji': '🍳'},
    {'id': 'advanced', 'emoji': '👨‍🍳'},
  ];

  Future<void> _buildPlan() async {
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().updateSetupData(
      cookingTime: _cookingTime,
      skillLevel: _skillLevel,
      onboardingComplete: true,
    );
    setState(() => _isLoading = false);
    if (mounted) context.push(AppRouter.setupComplete, extra: null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _SetupShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SetupProgressWidget(current: 5, total: 5),
          Expanded(
            child: Padding(
              padding: AppPad.h24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppGap.h8,
                  Text(
                    'onboarding_setup.about_you'.tr(),
                    style: AppTextStyles.s20.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      color: colors.textPrimary,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    'onboarding_setup.cooking_experience'.tr(),
                    style: AppTextStyles.s14.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  AppGap.h28,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SetupSubHeaderWidget(
                            'onboarding_setup.available_time'.tr(),
                          ),
                          AppGap.h12,
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.5,
                            children: _times.map((t) {
                              final isSelected =
                                  _cookingTime == t['id'] as String;
                              return GestureDetector(
                                onTap: () => setState(
                                  () => _cookingTime = t['id'] as String,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: AppPad.h12v8,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : colors.cardSurface,
                                    borderRadius: AppBorderRadius.a14,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        t['icon'] as IconData,
                                        size: 20,
                                        color: isSelected
                                            ? AppColors.primary
                                            : colors.textSecondary,
                                      ),
                                      AppGap.w8,
                                      Flexible(
                                        child: Text(
                                          _cookingTimeLabel(t['id'] as String),
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.s14.copyWith(
                                            color: isSelected
                                                ? AppColors.primary
                                                : colors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          AppGap.h24,
                          SetupSubHeaderWidget(
                            'onboarding_setup.cooking_skill'.tr(),
                          ),
                          AppGap.h12,
                          ..._skills.map((s) {
                            final isSelected = _skillLevel == s['id'] as String;
                            return Padding(
                              padding: AppPad.b10,
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _skillLevel = s['id'] as String,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: AppPad.a14,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : colors.cardSurface,
                                    borderRadius: AppBorderRadius.a14,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        s['emoji'] as String,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      AppGap.w14,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _skillLabel(s['id'] as String),
                                              style: AppTextStyles.s14.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : colors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              _skillDesc(s['id'] as String),
                                              style: AppTextStyles.s12.copyWith(
                                                color: colors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          AppGap.h24,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              height: 54,
              child: _isLoading
                  ? ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.a16,
                        ),
                      ),
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _buildPlan,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: Text('onboarding_setup.build_plan'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.a16,
                        ),
                        textStyle: AppTextStyles.s16.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
