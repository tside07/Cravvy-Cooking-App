import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_section.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_content.dart';
import 'package:cravvy_cooking_app/modules/legal/widgets/legal_scaffold_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _lastUpdated = '12 Tháng 6, 2026';

  List<LegalSection> _sections() => [
        LegalSection(
          icon: Icons.visibility_outlined,
          color: const Color(0xFF3B82F6),
          title: 'legal.privacy.s1_title'.tr(),
          content: [
            LegalContent(
              subtitle: 'legal.privacy.s1_c1_subtitle'.tr(),
              text: 'legal.privacy.s1_c1_text'.tr(),
            ),
            LegalContent(
              subtitle: 'legal.privacy.s1_c2_subtitle'.tr(),
              text: 'legal.privacy.s1_c2_text'.tr(),
            ),
            LegalContent(
              subtitle: 'legal.privacy.s1_c3_subtitle'.tr(),
              text: 'legal.privacy.s1_c3_text'.tr(),
            ),
            LegalContent(
              subtitle: 'legal.privacy.s1_c4_subtitle'.tr(),
              text: 'legal.privacy.s1_c4_text'.tr(),
            ),
          ],
        ),
        LegalSection(
          icon: Icons.lock_outline_rounded,
          color: const Color(0xFF6366F1),
          title: 'legal.privacy.s2_title'.tr(),
          content: [
            LegalContent(
              subtitle: 'legal.privacy.s2_c1_subtitle'.tr(),
              text: 'legal.privacy.s2_c1_text'.tr(),
            ),
            LegalContent(
              subtitle: 'legal.privacy.s2_c2_subtitle'.tr(),
              text: 'legal.privacy.s2_c2_text'.tr(),
            ),
            LegalContent(
              subtitle: 'legal.privacy.s2_c3_subtitle'.tr(),
              text: 'legal.privacy.s2_c3_text'.tr(),
            ),
          ],
        ),
        LegalSection(
          icon: Icons.people_outline_rounded,
          color: const Color(0xFF8B5CF6),
          title: 'legal.privacy.s3_title'.tr(),
          content: [
            LegalContent(text: 'legal.privacy.s3_c1_text'.tr()),
          ],
        ),
        LegalSection(
          icon: Icons.security_outlined,
          color: const Color(0xFF22C55E),
          title: 'legal.privacy.s4_title'.tr(),
          content: [
            LegalContent(text: 'legal.privacy.s4_c1_text'.tr()),
          ],
        ),
        LegalSection(
          icon: Icons.person_outline_rounded,
          color: const Color(0xFFF77C0F),
          title: 'legal.privacy.s5_title'.tr(),
          content: [
            LegalContent(text: 'legal.privacy.s5_c1_text'.tr()),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return LegalScaffoldWidget(
      title: 'legal.privacy.title'.tr(),
      lastUpdated: _lastUpdated,
      intro: 'legal.privacy.intro'.tr(),
      sections: _sections(),
    );
  }
}
