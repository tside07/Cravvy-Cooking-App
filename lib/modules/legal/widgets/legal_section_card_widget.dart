import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_section.dart';
import 'legal_content_item_widget.dart';

/// A card that renders one [LegalSection]: icon badge, title, and all
/// content paragraphs.
class LegalSectionCardWidget extends StatelessWidget {
  const LegalSectionCardWidget({super.key, required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: context.cardBox(radius: 20).copyWith(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + title row ───────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: section.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(section.icon, color: section.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: context.themed(
                    AppTextStyles.s16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: colors.borderDivider),
          const SizedBox(height: 16),

          // ── Content items ─────────────────────────────────────────────
          ...section.content.map((content) {
            final isLast = content == section.content.last;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: LegalContentItemWidget(content: content),
            );
          }),
        ],
      ),
    );
  }
}
