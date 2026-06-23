import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:cravvy_cooking_app/modules/legal/models/legal_content.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_section.dart';

/// Which legal document to render.
enum LegalDoc { terms, privacy, disclaimer }

/// Resolved content for one legal document.
class LegalDocData {
  const LegalDocData({
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String lastUpdated;
  final String intro;
  final List<LegalSection> sections;
}

/// Single source of truth for legal content, shared by the full-screen pages
/// (Settings) and the auth modal sheet. Keep i18n keys in sync with
/// assets/translations/*/legal.*.
abstract final class LegalDocs {
  static const String lastUpdated = '17 Tháng 6, 2026';

  static LegalDocData of(LegalDoc doc) {
    switch (doc) {
      case LegalDoc.terms:
        return _terms();
      case LegalDoc.privacy:
        return _privacy();
      case LegalDoc.disclaimer:
        return _disclaimer();
    }
  }

  static LegalDocData _terms() => LegalDocData(
        title: 'legal.terms.title'.tr(),
        lastUpdated: lastUpdated,
        intro: 'legal.terms.intro'.tr(),
        sections: [
          LegalSection(
            icon: Icons.handshake_outlined,
            color: const Color(0xFF3B82F6),
            title: 'legal.terms.s1_title'.tr(),
            content: [LegalContent(text: 'legal.terms.s1_c1_text'.tr())],
          ),
          LegalSection(
            icon: Icons.verified_user_outlined,
            color: const Color(0xFF22C55E),
            title: 'legal.terms.s2_title'.tr(),
            content: [LegalContent(text: 'legal.terms.s2_c1_text'.tr())],
          ),
          LegalSection(
            icon: Icons.account_circle_outlined,
            color: const Color(0xFF6366F1),
            title: 'legal.terms.s3_title'.tr(),
            content: [LegalContent(text: 'legal.terms.s3_c1_text'.tr())],
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
            content: [LegalContent(text: 'legal.terms.s5_c1_text'.tr())],
          ),
          LegalSection(
            icon: Icons.gavel_rounded,
            color: const Color(0xFF8B5CF6),
            title: 'legal.terms.s6_title'.tr(),
            content: [LegalContent(text: 'legal.terms.s6_c1_text'.tr())],
          ),
        ],
      );

  static LegalDocData _privacy() => LegalDocData(
        title: 'legal.privacy.title'.tr(),
        lastUpdated: lastUpdated,
        intro: 'legal.privacy.intro'.tr(),
        sections: [
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
            content: [LegalContent(text: 'legal.privacy.s3_c1_text'.tr())],
          ),
          LegalSection(
            icon: Icons.security_outlined,
            color: const Color(0xFF22C55E),
            title: 'legal.privacy.s4_title'.tr(),
            content: [LegalContent(text: 'legal.privacy.s4_c1_text'.tr())],
          ),
          LegalSection(
            icon: Icons.person_outline_rounded,
            color: const Color(0xFFF77C0F),
            title: 'legal.privacy.s5_title'.tr(),
            content: [LegalContent(text: 'legal.privacy.s5_c1_text'.tr())],
          ),
        ],
      );

  static LegalDocData _disclaimer() => LegalDocData(
        title: 'legal.disclaimer.title'.tr(),
        lastUpdated: lastUpdated,
        intro: 'legal.disclaimer.intro'.tr(),
        sections: [
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
            content: [LegalContent(text: 'legal.disclaimer.s2_c1_text'.tr())],
          ),
          LegalSection(
            icon: Icons.psychology_outlined,
            color: const Color(0xFF8B5CF6),
            title: 'legal.disclaimer.s3_title'.tr(),
            content: [LegalContent(text: 'legal.disclaimer.s3_c1_text'.tr())],
          ),
          LegalSection(
            icon: Icons.info_outline_rounded,
            color: const Color(0xFF3B82F6),
            title: 'legal.disclaimer.s4_title'.tr(),
            content: [LegalContent(text: 'legal.disclaimer.s4_c1_text'.tr())],
          ),
          LegalSection(
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF22C55E),
            title: 'legal.disclaimer.s5_title'.tr(),
            content: [LegalContent(text: 'legal.disclaimer.s5_c1_text'.tr())],
          ),
        ],
      );
}
