import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_content.dart';

/// Renders a single [LegalContent] item — an optional subtitle followed by
/// the paragraph text.
class LegalContentItemWidget extends StatelessWidget {
  const LegalContentItemWidget({super.key, required this.content});

  final LegalContent content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.subtitle != null) ...[
          Text(
            content.subtitle!,
            style: AppTextStyles.s14.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          AppGap.h4,
        ],
        Text(
          content.text,
          style: AppTextStyles.s14.copyWith(
            color: AppColors.textSecondary,
            height: 1.65,
          ),
        ),
      ],
    );
  }
}
