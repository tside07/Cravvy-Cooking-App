import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_progress_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_select_chip_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_input_label_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_sub_header_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_num_field_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_continue_button_widget.dart';

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

  String get _bmiCategory {
    final b = _bmi;
    if (b == null) return '';
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    final b = _bmi;
    if (b == null) return AppColors.textSecondary;
    if (b < 18.5) return AppColors.warning;
    if (b < 25) return AppColors.success;
    if (b < 30) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SetupProgressWidget(current: 1, total: 5),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppGap.h8,
                    Text(
                      "Let's personalize your experience",
                      style: AppTextStyles.s20.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                    AppGap.h8,
                    Text(
                      'Your meals will be tailored to your body and goals',
                      style: AppTextStyles.s14
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    AppGap.h28,

                    const SetupInputLabelWidget('Age'),
                    AppGap.h8,
                    SetupNumFieldWidget(
                      controller: _ageCtrl,
                      hint: 'Enter age',
                      onChanged: (_) => setState(() {}),
                    ),
                    AppGap.h20,

                    const SetupInputLabelWidget('Gender'),
                    AppGap.h8,
                    Row(
                      children: ['Male', 'Female', 'Other']
                          .map(
                            (g) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: g != 'Other' ? 8 : 0),
                                child: GestureDetector(
                                  onTap: () => setState(() => _gender = g),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: _gender == g
                                          ? AppColors.primary
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: _gender == g
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        g,
                                        style: AppTextStyles.s14.copyWith(
                                          color: _gender == g
                                              ? Colors.white
                                              : AppColors.textPrimary,
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

                    const SetupInputLabelWidget('Height (cm)'),
                    AppGap.h8,
                    SetupNumFieldWidget(
                      controller: _heightCtrl,
                      hint: 'e.g. 170',
                      onChanged: (_) => setState(() {}),
                    ),
                    AppGap.h20,

                    const SetupInputLabelWidget('Weight (kg)'),
                    AppGap.h8,
                    SetupNumFieldWidget(
                      controller: _weightCtrl,
                      hint: 'e.g. 70',
                      onChanged: (_) => setState(() {}),
                    ),
                    AppGap.h20,

                    if (_bmi != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your BMI',
                                    style: AppTextStyles.s12.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  AppGap.h4,
                                  Text(
                                    _bmi!.toStringAsFixed(1),
                                    style: AppTextStyles.s20.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _bmiColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _bmiCategory,
                                style: AppTextStyles.s14.copyWith(
                                  color: _bmiColor,
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
            SetupContinueButtonWidget(
              onPressed: () => context.push(AppRouter.setupStep2),
            ),
          ],
        ),
      ),
    );
  }
}

class SetupStep2Screen extends StatefulWidget {
  const SetupStep2Screen({super.key});

  @override
  State<SetupStep2Screen> createState() => _SetupStep2ScreenState();
}

class _SetupStep2ScreenState extends State<SetupStep2Screen> {
  String _selectedGoal = 'lose-weight';

  static const _goals = [
    {
      'id': 'lose-weight',
      'title': 'Lose Weight',
      'desc': 'Burn fat, feel lighter',
      'icon': Icons.local_fire_department_rounded,
      'color': 0xFFEF4444,
    },
    {
      'id': 'build-muscle',
      'title': 'Build Muscle',
      'desc': 'Gain strength & mass',
      'icon': Icons.fitness_center_rounded,
      'color': 0xFF3B82F6,
    },
    {
      'id': 'maintain',
      'title': 'Maintain Weight',
      'desc': 'Stay balanced & healthy',
      'icon': Icons.balance_rounded,
      'color': 0xFF6A8A42,
    },
    {
      'id': 'health',
      'title': 'Manage Condition',
      'desc': 'Diet for health needs',
      'icon': Icons.favorite_rounded,
      'color': 0xFF8B5CF6,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SetupProgressWidget(current: 2, total: 5),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppGap.h8,
                    Text(
                      "What's your main goal?",
                      style: AppTextStyles.s20.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                    AppGap.h8,
                    Text(
                      "We'll customize your meal plan to help you achieve it",
                      style: AppTextStyles.s14
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    AppGap.h28,
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                        children: _goals.map((g) {
                          final isSelected =
                              _selectedGoal == g['id'] as String;
                          final color = Color(g['color'] as int);
                          return GestureDetector(
                            onTap: () => setState(
                                () => _selectedGoal = g['id'] as String),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
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
                                          : color.withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      g['icon'] as IconData,
                                      color:
                                          isSelected ? Colors.white : color,
                                      size: 24,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    g['title'] as String,
                                    style: AppTextStyles.s14.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  AppGap.h4,
                                  Text(
                                    g['desc'] as String,
                                    style: AppTextStyles.s12.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SetupContinueButtonWidget(
              onPressed: () => context.push(AppRouter.setupStep3),
            ),
          ],
        ),
      ),
    );
  }
}


class SetupStep3Screen extends StatefulWidget {
  const SetupStep3Screen({super.key});

  @override
  State<SetupStep3Screen> createState() => _SetupStep3ScreenState();
}

class _SetupStep3ScreenState extends State<SetupStep3Screen> {
  final Set<String> _selected = {};

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
        if (_selected.contains(diet))
          _selected.remove(diet);
        else
          _selected.add(diet);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SetupProgressWidget(current: 3, total: 5),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppGap.h8,
                    Text(
                      'Do you follow any diet?',
                      style: AppTextStyles.s20.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                    AppGap.h8,
                    Text(
                      'Select all that apply',
                      style: AppTextStyles.s14
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    AppGap.h24,
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _diets
                          .map(
                            (d) => SetupSelectChipWidget(
                              label: d,
                              selected: _selected.contains(d),
                              onTap: () => _toggle(d),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            SetupContinueButtonWidget(
              onPressed: () => context.push(AppRouter.setupStep4),
            ),
          ],
        ),
      ),
    );
  }
}


class SetupStep4Screen extends StatefulWidget {
  const SetupStep4Screen({super.key});

  @override
  State<SetupStep4Screen> createState() => _SetupStep4ScreenState();
}

class _SetupStep4ScreenState extends State<SetupStep4Screen> {
  final Set<String> _selected = {};
  bool _noRestrictions = false;
  final _customCtrl = TextEditingController();

  static const _allergies = [
    'Peanuts', 'Shellfish', 'Dairy', 'Gluten',
    'Eggs', 'Soy', 'Tree Nuts', 'Fish',
  ];
  static const _prefs = [
    'No Pork', 'No Beef', 'No Seafood', 'No Spicy', 'No Raw Foods',
  ];

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _toggle(String item) {
    setState(() {
      _noRestrictions = false;
      if (_selected.contains(item))
        _selected.remove(item);
      else
        _selected.add(item);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SetupProgressWidget(current: 4, total: 5),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppGap.h8,
                    Text(
                      'Any foods to avoid?',
                      style: AppTextStyles.s20.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                    AppGap.h8,
                    Text(
                      "We'll never suggest these in your meals",
                      style: AppTextStyles.s14
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    AppGap.h24,

                    const SetupSubHeaderWidget('Allergies'),
                    AppGap.h10,
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _allergies
                          .map(
                            (a) => SetupSelectChipWidget(
                              label: a,
                              selected: _selected.contains(a),
                              onTap: () => _toggle(a),
                            ),
                          )
                          .toList(),
                    ),
                    AppGap.h20,

                    const SetupSubHeaderWidget('Food Preferences'),
                    AppGap.h10,
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _prefs
                          .map(
                            (p) => SetupSelectChipWidget(
                              label: p,
                              selected: _selected.contains(p),
                              onTap: () => _toggle(p),
                            ),
                          )
                          .toList(),
                    ),
                    AppGap.h20,

                    const SetupSubHeaderWidget('Add Custom'),
                    AppGap.h10,
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. Mushrooms',
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addCustom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white),
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
                                  s,
                                  style: AppTextStyles.s12
                                      .copyWith(color: AppColors.primary),
                                ),
                                backgroundColor: AppColors.primaryLight,
                                deleteIcon: const Icon(Icons.close_rounded,
                                    size: 14, color: AppColors.primary),
                                onDeleted: () =>
                                    setState(() => _selected.remove(s)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                      color: Colors.transparent),
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
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _noRestrictions
                              ? AppColors.primaryLight
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
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
                                  : AppColors.textHint,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'No restrictions — I eat everything!',
                              style: AppTextStyles.s14.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _noRestrictions
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
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
            SetupContinueButtonWidget(
              onPressed: () => context.push(AppRouter.setupStep5),
            ),
          ],
        ),
      ),
    );
  }
}


class SetupStep5Screen extends StatefulWidget {
  const SetupStep5Screen({super.key});

  @override
  State<SetupStep5Screen> createState() => _SetupStep5ScreenState();
}

class _SetupStep5ScreenState extends State<SetupStep5Screen> {
  String _cookingTime = 'short';
  String _skillLevel = 'intermediate';

  static const _times = [
    {'id': 'quick', 'label': 'Under 15 min', 'icon': Icons.bolt_rounded},
    {'id': 'short', 'label': '15–30 min', 'icon': Icons.schedule_rounded},
    {'id': 'medium', 'label': '30–60 min', 'icon': Icons.timer_outlined},
    {
      'id': 'long',
      'label': '1 hour+',
      'icon': Icons.restaurant_menu_rounded,
    },
  ];

  static const _skills = [
    {
      'id': 'beginner',
      'emoji': '🥚',
      'label': 'Beginner',
      'desc': 'Simple recipes',
    },
    {
      'id': 'intermediate',
      'emoji': '🍳',
      'label': 'Intermediate',
      'desc': 'Moderate skills',
    },
    {
      'id': 'advanced',
      'emoji': '👨‍🍳',
      'label': 'Advanced',
      'desc': 'Complex dishes',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SetupProgressWidget(current: 5, total: 5),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppGap.h8,
                    Text(
                      'A few more things about you',
                      style: AppTextStyles.s20.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                    AppGap.h8,
                    Text(
                      'Help us personalize your cooking experience',
                      style: AppTextStyles.s14
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    AppGap.h28,

                    const SetupSubHeaderWidget('Available cooking time'),
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
                              () => _cookingTime = t['id'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
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
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    t['label'] as String,
                                    style: AppTextStyles.s14.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
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
                    const SetupSubHeaderWidget('Cooking skill level'),
                    AppGap.h12,
                    Column(
                      children: _skills.map((s) {
                        final isSelected = _skillLevel == s['id'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _skillLevel = s['id'] as String),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
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
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['label'] as String,
                                          style: AppTextStyles.s14.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          s['desc'] as String,
                                          style: AppTextStyles.s12.copyWith(
                                            color: AppColors.textSecondary,
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
                      }).toList(),
                    ),
                    AppGap.h24,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRouter.setupComplete),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                  label: const Text('Build My Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
      ),
    );
  }
}
