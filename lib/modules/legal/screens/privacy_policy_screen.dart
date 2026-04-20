import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_section.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_content.dart';
import 'package:cravvy_cooking_app/modules/legal/widgets/legal_scaffold_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    LegalSection(
      icon: Icons.visibility_outlined,
      color: Color(0xFF3B82F6),
      title: 'Data Collection',
      content: [
        LegalContent(
          subtitle: 'Personal Information',
          text:
              'We collect your name, email, date of birth, and gender when you register. This helps personalize your experience and communicate with you.',
        ),
        LegalContent(
          subtitle: 'Health & Nutrition Data',
          text:
              'Weight, height, health goals, and conditions (allergies, special diets) are collected so AI can provide appropriate nutrition suggestions. This data is encrypted and stored securely.',
        ),
        LegalContent(
          subtitle: 'AI Interactions',
          text:
              'Chat history with AI, viewed recipes, dish ratings, and shopping history help the system learn and improve suggestions over time.',
        ),
        LegalContent(
          subtitle: 'Device Data',
          text:
              'We automatically collect device information (type, OS, IP), app usage data (popular features, time spent) to optimize performance and detect errors.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.lock_outline_rounded,
      color: Color(0xFF6366F1),
      title: 'Data Use',
      content: [
        LegalContent(
          subtitle: 'AI Personalization',
          text:
              'Nutrition data, preferences and goals are used to train a personal AI model, delivering tailored recipe, daily menu and nutrition advice recommendations.',
        ),
        LegalContent(
          subtitle: 'Service Improvement',
          text:
              'Analyzing user behavior (popular features, bottlenecks) helps us optimize the experience, develop new features, and fix bugs.',
        ),
        LegalContent(
          subtitle: 'Communication',
          text:
              'Email is used to send account verification, password reset, important update notifications and (if you subscribe) weekly nutrition tips.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.people_outline_rounded,
      color: Color(0xFF8B5CF6),
      title: 'Data Sharing',
      content: [
        LegalContent(
          text:
              'We never sell personal data. We only share data with: (1) Cloud service providers (AWS, Firebase) to store and process data; (2) Payment partners (licensed gateways) to process transactions; (3) Analytics tools (anonymized, non-personal data); (4) Legal authorities when required by law.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.security_outlined,
      color: Color(0xFF22C55E),
      title: 'Security',
      content: [
        LegalContent(
          text:
              'All data is encrypted in transit (TLS 1.3) and at rest (AES-256). We conduct regular security audits and limit employee access to personal data strictly on a need-to-know basis.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.person_outline_rounded,
      color: Color(0xFFF77C0F),
      title: 'Your Rights',
      content: [
        LegalContent(
          text:
              'You can: (1) Access all your data via Settings → Export My Data; (2) Correct inaccurate information via Edit Profile; (3) Delete all data via Settings → Delete Account; (4) Opt out of marketing emails at any time. Requests are processed within 30 days.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LegalScaffoldWidget(
      title: 'Privacy Policy',
      lastUpdated: 'January 15, 2025',
      intro:
          'Cravvy ("we", "us") is committed to protecting your privacy. This policy explains how we collect, use, and protect your personal information when using the Cravvy app.',
      sections: _sections,
    );
  }
}
