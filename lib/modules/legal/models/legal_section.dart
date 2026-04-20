import 'package:flutter/material.dart';
import 'legal_content.dart';

/// A titled section of a legal page (e.g. "Data Collection", "Allergies").
class LegalSection {
  final IconData icon;
  final Color color;
  final String title;
  final List<LegalContent> content;

  const LegalSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
  });
}
