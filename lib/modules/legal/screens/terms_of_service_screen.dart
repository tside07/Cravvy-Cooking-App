import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_section.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_content.dart';
import 'package:cravvy_cooking_app/modules/legal/widgets/legal_scaffold_widget.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const _sections = [
    LegalSection(
      icon: Icons.handshake_outlined,
      color: Color(0xFF3B82F6),
      title: 'Acceptance of Terms',
      content: [
        LegalContent(
          text:
              'By downloading, installing, or using the Cravvy application ("App"), you agree to be bound by these Terms of Service. If you do not agree to all terms, do not use the App. These terms constitute a legally binding agreement between you and Cravvy.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.verified_user_outlined,
      color: Color(0xFF22C55E),
      title: 'User Eligibility',
      content: [
        LegalContent(
          text:
              'You must be at least 16 years old to create an account. If you are between 16 and 18, you must have parental or guardian consent. By registering, you confirm that all information provided is accurate and that you meet the eligibility requirements.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.account_circle_outlined,
      color: Color(0xFF6366F1),
      title: 'Account Responsibilities',
      content: [
        LegalContent(
          text:
              'You are responsible for maintaining the confidentiality of your account credentials. You agree to: (1) Provide accurate account information; (2) Not share your account with others; (3) Notify us immediately of any unauthorized access; (4) Accept responsibility for all activities under your account.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.workspace_premium_outlined,
      color: Color(0xFFF59E0B),
      title: 'Premium Subscription',
      content: [
        LegalContent(
          subtitle: 'Billing',
          text:
              'Premium subscriptions are billed monthly (149,000đ) or annually (999,000đ). Payments are processed through your app store account. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.',
        ),
        LegalContent(
          subtitle: 'Cancellation & Refunds',
          text:
              'You may cancel your subscription anytime via Settings → Subscription. Access continues until the end of the billing period. Refunds are handled according to the policies of your app store (Google Play / Apple App Store).',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.block_outlined,
      color: Color(0xFFEF4444),
      title: 'Prohibited Conduct',
      content: [
        LegalContent(
          text:
              'You agree not to: (1) Use the App for any unlawful purpose; (2) Attempt to reverse-engineer, decompile, or hack the App; (3) Scrape, harvest, or collect data from the App without authorization; (4) Upload malicious content or interfere with the App\'s operation; (5) Impersonate another person or misrepresent your affiliation.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.gavel_rounded,
      color: Color(0xFF8B5CF6),
      title: 'Limitation of Liability',
      content: [
        LegalContent(
          text:
              'Cravvy is provided "as is" without warranties of any kind. We are not liable for: (1) Health outcomes resulting from following AI suggestions; (2) Data loss due to system failures; (3) Interruption of service; (4) Third-party content or links. Our total liability shall not exceed the amount you paid for Premium in the preceding 12 months.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LegalScaffoldWidget(
      title: 'Terms of Service',
      lastUpdated: 'January 15, 2025',
      intro:
          'Please read these Terms of Service carefully before using the Cravvy application. These terms govern your use of our app and services.',
      sections: _sections,
    );
  }
}
