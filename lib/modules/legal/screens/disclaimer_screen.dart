import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_section.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_content.dart';
import 'package:cravvy_cooking_app/modules/legal/widgets/legal_scaffold_widget.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  static const _sections = [
    LegalSection(
      icon: Icons.favorite_border_rounded,
      color: Color(0xFFEF4444),
      title: 'Not a Medical Substitute',
      content: [
        LegalContent(
          text:
              'Nutritional suggestions and menus from AI are for reference only. They are not medical advice, disease diagnosis, or treatment prescriptions. If you have a medical condition (diabetes, hypertension, kidney disease), consult a doctor or dietitian before changing your diet. AI may suggest dishes based on data you provide, but does not fully understand your personal health status.',
        ),
        LegalContent(
          subtitle: 'Special groups',
          text:
              'Pregnant women, nursing mothers, children, and the elderly require special nutritional regimens — always consult a specialist.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFF59E0B),
      title: 'Allergies & Food Safety',
      content: [
        LegalContent(
          text:
              'Cravvy filters recipes based on the allergy information you declare. However, AI may miss allergen ingredients (e.g., peanuts hidden in sauces, gluten in spices). ALWAYS check product labels and ingredient lists before cooking if you have serious allergies. We are not liable for allergic reactions or food poisoning from following recipes.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.psychology_outlined,
      color: Color(0xFF8B5CF6),
      title: 'Limitations of AI',
      content: [
        LegalContent(
          text:
              'Cravvy\'s AI is trained on public data but is not perfect. Nutritional information (calories, macros) may be off by ±10% due to ingredient and preparation method differences. AI may generate suggestions that are culturally inappropriate or not feasible with locally available ingredients. In rare cases, AI may suggest unsafe ingredient combinations — always use your own culinary judgment.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.info_outline_rounded,
      color: Color(0xFF3B82F6),
      title: 'Data Accuracy',
      content: [
        LegalContent(
          text:
              'Nutritional data is sourced from USDA FoodData Central and the National Institute of Nutrition. Despite regular review, there may be discrepancies with actual product values. Use this data as a general guide, not a precise measurement tool — especially important for people with serious health conditions.',
        ),
      ],
    ),
    LegalSection(
      icon: Icons.check_circle_outline_rounded,
      color: Color(0xFF22C55E),
      title: 'Responsible Use',
      content: [
        LegalContent(
          text:
              'By using Cravvy you acknowledge: (1) Nutritional information is for reference only; (2) You take personal responsibility for food choices; (3) You will consult professionals for serious health issues; (4) Cravvy is a support tool, not a replacement for expert medical and nutritional advice.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LegalScaffoldWidget(
      title: 'Disclaimer',
      lastUpdated: 'January 15, 2025',
      intro:
          'Important information about the limitations of Cravvy\'s AI nutritional recommendations. Please read carefully before using our service.',
      sections: _sections,
    );
  }
}
