import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/profile/provider/profile_provider.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/profile_stat_box_widget.dart';
import 'package:cravvy_cooking_app/modules/profile/widgets/profile_vsep_widget.dart';
import 'package:cravvy_cooking_app/modules/onboarding/provider/onboarding_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileHeaderCardWidget extends StatelessWidget {
  const ProfileHeaderCardWidget({
    super.key,
    required this.profile,
    required this.goal,
  });

  final ProfileProvider profile;
  final HealthGoal? goal;

  @override
  Widget build(BuildContext context) {
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
          Text(
            profile.name,
            style: AppTextStyles.s20.copyWith(fontWeight: FontWeight.w800),
          ),
          AppGap.h4,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              AppGap.w4,
              Text(
                profile.email,
                style: AppTextStyles.s12.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          AppGap.h4,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              AppGap.w4,
              Text(
                profile.phone,
                style: AppTextStyles.s12.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          AppGap.h8,
          if (profile.bio.isNotEmpty) ...[
            Text(
              profile.bio,
              textAlign: TextAlign.center,
              style: AppTextStyles.s12.copyWith(color: AppColors.textSecondary),
            ),
            AppGap.h10,
          ],
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
                  const Icon(
                    Icons.flag_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
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
          Container(
            padding: AppPad.a12,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppBorderRadius.a16,
            ),
            child: Row(
              children: [
                ProfileStatBoxWidget(
                  label: 'profile.stat_age'.tr(),
                  value: '${profile.age}',
                ),
                const ProfileVSepWidget(),
                ProfileStatBoxWidget(
                  label: 'profile.stat_height'.tr(),
                  value: '${profile.heightCm}cm',
                ),
                const ProfileVSepWidget(),
                ProfileStatBoxWidget(
                  label: 'profile.stat_weight'.tr(),
                  value: '${profile.weightKg.toStringAsFixed(0)}kg',
                ),
              ],
            ),
          ),
          AppGap.h10,
          Container(
            width: double.infinity,
            padding: AppPad.h16v10,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppBorderRadius.a12,
            ),
            child: Text(
              'BMI: ${profile.bmi.toStringAsFixed(1)} (${profile.bmiLabel})',
              textAlign: TextAlign.center,
              style: AppTextStyles.s12.copyWith(
                fontSize: 13,
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppGap.h12,
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
                  const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  AppGap.w8,
                  Text(
                    'profile.edit_personal_info'.tr(),
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
