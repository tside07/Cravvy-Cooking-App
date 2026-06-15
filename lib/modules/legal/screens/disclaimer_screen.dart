import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_section.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_content.dart';
import 'package:cravvy_cooking_app/modules/legal/widgets/legal_scaffold_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  static const _lastUpdated = '12 Tháng 6, 2026';

  List<LegalSection> _sections() => [
        LegalSection(
          icon: Icons.favorite_border_rounded,
          color: const Color(0xFFEF4444),
          title: 'legal.disclaimer.s1_title'.tr(),
          content: [
            LegalContent(text: 'legal.disclaimer.s1_c1_text'.tr()),
            LegalContent(
              subtitle: 'legal.disclaimer.s1_c2_subtitle'.tr(),
              text: 'legal.disclaimer.s1_c2_text'.tr(),
            ),
          ],
        ),
        LegalSection(
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFF59E0B),
          title: 'legal.disclaimer.s2_title'.tr(),
          content: [
            LegalContent(text: 'legal.disclaimer.s2_c1_text'.tr()),
          ],
        ),
        LegalSection(
          icon: Icons.psychology_outlined,
          color: const Color(0xFF8B5CF6),
          title: 'legal.disclaimer.s3_title'.tr(),
          content: [
            LegalContent(text: 'legal.disclaimer.s3_c1_text'.tr()),
          ],
        ),
        LegalSection(
          icon: Icons.info_outline_rounded,
          color: const Color(0xFF3B82F6),
          title: 'legal.disclaimer.s4_title'.tr(),
          content: [
            LegalContent(text: 'legal.disclaimer.s4_c1_text'.tr()),
          ],
        ),
        LegalSection(
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF22C55E),
          title: 'legal.disclaimer.s5_title'.tr(),
          content: [
            LegalContent(text: 'legal.disclaimer.s5_c1_text'.tr()),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return LegalScaffoldWidget(
      title: 'legal.disclaimer.title'.tr(),
      lastUpdated: _lastUpdated,
      intro: 'legal.disclaimer.intro'.tr(),
      sections: _sections(),
    );
  }
}
