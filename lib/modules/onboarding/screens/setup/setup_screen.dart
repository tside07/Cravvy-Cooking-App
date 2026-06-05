import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/data/providers/auth_provider.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_progress_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_select_chip_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_input_label_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_sub_header_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_num_field_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/widgets/setup/setup_continue_button_widget.dart';

// TODO: Helper: bọc body để fix infinite width trên cả web lẫn mobile
// Mọi setup screen đều dùng cái này thay vì Scaffold trực tiếp
class _SetupShell extends StatelessWidget {
  const _SetupShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: child,
                ),
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

  Future<void> _continue() async {
    final age = int.tryParse(_ageCtrl.text);
    final height = double.tryParse(_heightCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);

    if (age == null || height == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
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
                        "Let's personalize your experience",
                        style: AppTextStyles.s20.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                      AppGap.h8,
                      Text(
                        'Your meals will be tailored to your body and goals',
                        style: AppTextStyles.s14.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
                          padding: AppPad.a16,
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
                                padding: AppPad.h12,
                                decoration: BoxDecoration(
                                  color: _bmiColor.withValues(alpha: 0.1),
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

  Future<void> _continue() async {
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().updateSetupData(goal: _selectedGoal);
    setState(() => _isLoading = false);
    if (mounted) context.push(AppRouter.setupStep3);
  }

  @override
  Widget build(BuildContext context) {
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
                    "What's your main goal?",
                    style: AppTextStyles.s20.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    "We'll customize your meal plan to help you achieve it",
                    style: AppTextStyles.s14.copyWith(
                      color: AppColors.textSecondary,
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
                                  : AppColors.surface,
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
                    'Do you follow any diet?',
                    style: AppTextStyles.s20.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    'Select all that apply',
                    style: AppTextStyles.s14.copyWith(
                      color: AppColors.textSecondary,
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
                                label: d,
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
                    'Any foods to avoid?',
                    style: AppTextStyles.s20.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    "We'll never suggest these in your meals",
                    style: AppTextStyles.s14.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppGap.h24,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                          // KEY FIX: Row cần parent có bounded width
                          // crossAxisAlignment.stretch trên Column cha đảm bảo điều này
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
                                        s,
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
                                    : AppColors.surface,
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
                                        : AppColors.textHint,
                                  ),
                                  AppGap.w10,
                                  Expanded(
                                    child: Text(
                                      'No restrictions — I eat everything!',
                                      style: AppTextStyles.s14.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _noRestrictions
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
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
    {'id': 'quick', 'label': 'Under 15 min', 'icon': Icons.bolt_rounded},
    {'id': 'short', 'label': '15–30 min', 'icon': Icons.schedule_rounded},
    {'id': 'medium', 'label': '30–60 min', 'icon': Icons.timer_outlined},
    {'id': 'long', 'label': '1 hour+', 'icon': Icons.restaurant_menu_rounded},
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
                    'A few more things about you',
                    style: AppTextStyles.s20.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  AppGap.h8,
                  Text(
                    'Help us personalize your cooking experience',
                    style: AppTextStyles.s14.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppGap.h28,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                                  () => _cookingTime = t['id'] as String,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: AppPad.h12v8,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : AppColors.surface,
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
                                            : AppColors.textSecondary,
                                      ),
                                      AppGap.w8,
                                      Flexible(
                                        child: Text(
                                          t['label'] as String,
                                          overflow: TextOverflow.ellipsis,
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
                                        : AppColors.surface,
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
                      label: const Text('Build My Plan'),
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
