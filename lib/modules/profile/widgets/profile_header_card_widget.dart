import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:cravvy_cooking_app/modules/profile/provider/profile_provider.dart';

class ProfileHeaderCardWidget extends StatelessWidget {
  const ProfileHeaderCardWidget({super.key, required this.goal});

  final HealthGoal? goal;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Container(
      margin: const EdgeInsets.only(left: 16, top: 20, right: 16),
      padding: AppPad.a20,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.a24,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack15,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Avatar ────────────────────────────────────────────────────
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.initials,
                    style: AppTextStyles.s20.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 12,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          AppGap.h12,

          // ── Name ──────────────────────────────────────────────────────
          Text(
            profile.name,
            style: AppTextStyles.s20.copyWith(fontWeight: FontWeight.w800),
          ),
          AppGap.h4,

          // ── Email ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
              AppGap.w4,
              Text(
                profile.email,
                style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          AppGap.h4,

          // ── Phone ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
              AppGap.w4,
              Text(
                profile.phone,
                style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          AppGap.h8,

          // ── Bio ───────────────────────────────────────────────────────
          if (profile.bio.isNotEmpty) ...[
            Text(
              profile.bio,
              textAlign: TextAlign.center,
              style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary),
            ),
            AppGap.h10,
          ],

          // ── Goal chip ─────────────────────────────────────────────────
          if (goal != null)
            Container(
              padding: AppPad.h12v6,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppBorderRadius.a20,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag_rounded, size: 14, color: AppColors.primary),
                  AppGap.w4,
                  Text(
                    goal!.title,
                    style: AppTextStyles.s12.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          AppGap.h16,

          // ── Stats row: Age · Height · Weight ──────────────────────────
          Container(
            padding: AppPad.a12,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppBorderRadius.a16,
            ),
            child: Row(
              children: [
                _StatBox(label: 'Age', value: '${profile.age}'),
                _VSep(),
                _StatBox(label: 'Height', value: '${profile.heightCm}cm'),
                _VSep(),
                _StatBox(label: 'Weight', value: '${profile.weightKg.toStringAsFixed(0)}kg'),
              ],
            ),
          ),
          AppGap.h10,

          // ── BMI pill ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: AppPad.h16v10,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppBorderRadius.a12,
            ),
            child: Text(
              'BMI: ${profile.bmi.toStringAsFixed(1)}  (${profile.bmiLabel})',
              textAlign: TextAlign.center,
              style: AppTextStyles.s12.copyWith(
                fontSize: 13,
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppGap.h12,

          // ── Edit button ───────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.push(AppRouter.editProfile),
            child: Container(
              width: double.infinity,
              padding: AppPad.h16v12,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: AppBorderRadius.a12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  AppGap.w8,
                  Text(
                    'Edit personal info',
                    style: AppTextStyles.s14.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.s10.copyWith(color: AppColors.textSecondary),
          ),
          AppGap.h2,
          Text(
            value,
            style: AppTextStyles.s16.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _VSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.border);
}
