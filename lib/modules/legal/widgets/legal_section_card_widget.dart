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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
                  style: AppTextStyles.s16.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
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
