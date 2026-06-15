import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_section.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_content.dart';
import 'package:cravvy_cooking_app/modules/legal/widgets/legal_scaffold_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const _lastUpdated = '12 Tháng 6, 2026';

  List<LegalSection> _sections() => [
        LegalSection(
          icon: Icons.handshake_outlined,
          color: const Color(0xFF3B82F6),
          title: 'legal.terms.s1_title'.tr(),
          content: [
            LegalContent(text: 'legal.terms.s1_c1_text'.tr()),
          ],
        ),
        LegalSection(
          icon: Icons.verified_user_outlined,
          color: const Color(0xFF22C55E),
          title: 'legal.terms.s2_title'.tr(),
          content: [
            LegalContent(text: 'legal.terms.s2_c1_text'.tr()),
          ],
        ),
        LegalSection(
          icon: Icons.account_circle_outlined,
          color: const Color(0xFF6366F1),
          title: 'legal.terms.s3_title'.tr(),
          content: [
            LegalContent(text: 'legal.terms.s3_c1_text'.tr()),
          ],
        ),
        LegalSection(
          icon: Icons.workspace_premium_outlined,
          color: const Color(0xFFF59E0B),
          title: 'legal.terms.s4_title'.tr(),
          content: [
            LegalContent(
              subtitle: 'legal.terms.s4_c1_subtitle'.tr(),
              text: 'legal.terms.s4_c1_text'.tr(),
            ),
            LegalContent(
              subtitle: 'legal.terms.s4_c2_subtitle'.tr(),
              text: 'legal.terms.s4_c2_text'.tr(),
            ),
          ],
        ),
        LegalSection(
          icon: Icons.block_outlined,
          color: const Color(0xFFEF4444),
          title: 'legal.terms.s5_title'.tr(),
          content: [
            LegalContent(text: 'legal.terms.s5_c1_text'.tr()),
          ],
        ),
        LegalSection(
          icon: Icons.gavel_rounded,
          color: const Color(0xFF8B5CF6),
          title: 'legal.terms.s6_title'.tr(),
          content: [
            LegalContent(text: 'legal.terms.s6_c1_text'.tr()),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return LegalScaffoldWidget(
      title: 'legal.terms.title'.tr(),
      lastUpdated: _lastUpdated,
      intro: 'legal.terms.intro'.tr(),
      sections: _sections(),
    );
  }
}
