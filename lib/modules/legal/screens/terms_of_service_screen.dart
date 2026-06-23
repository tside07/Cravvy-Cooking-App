import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/modules/legal/legal_docs.dart';
import 'package:cravvy_cooking_app/modules/legal/widgets/legal_scaffold_widget.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = LegalDocs.of(LegalDoc.terms);
    return LegalScaffoldWidget(
      title: data.title,
      lastUpdated: data.lastUpdated,
      intro: data.intro,
      sections: data.sections,
    );
  }
}
