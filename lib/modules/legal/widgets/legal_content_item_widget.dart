import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/legal/models/legal_content.dart';

/// Renders a single [LegalContent] item — an optional subtitle followed by
/// the paragraph text.
class LegalContentItemWidget extends StatelessWidget {
  const LegalContentItemWidget({super.key, required this.content});

  final LegalContent content;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.subtitle != null) ...[
          Text(
            content.subtitle!,
            style: context.themed(
              AppTextStyles.s14,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppGap.h4,
        ],
        Text(
          content.text,
          style: context.themed(
            AppTextStyles.s14,
            color: colors.textSecondary,
          ).copyWith(height: 1.65),
        ),
      ],
    );
  }
}
