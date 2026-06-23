import 'package:cravvy_cooking_app/init.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:cravvy_cooking_app/core/theme/app_theme.dart';
import 'package:cravvy_cooking_app/modules/legal/legal_docs.dart';
import 'package:cravvy_cooking_app/modules/legal/widgets/legal_section_card_widget.dart';

/// Shows a legal document ([LegalDoc.terms] / [LegalDoc.privacy] /
/// [LegalDoc.disclaimer]) as a polished bottom-sheet modal — used in flows
/// where leaving the screen is undesirable (e.g. the register form).
///
/// The sheet is themed with [AppTheme.darkTheme] so it stays cohesive with the
/// fixed-dark pre-auth shell, regardless of the app's current theme mode.
Future<void> showLegalSheet(BuildContext context, LegalDoc doc) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => Theme(
      data: AppTheme.darkTheme,
      child: _LegalSheet(doc: doc),
    ),
  );
}

class _LegalSheet extends StatelessWidget {
  const _LegalSheet({required this.doc});

  final LegalDoc doc;

  IconData get _icon => switch (doc) {
        LegalDoc.terms => Icons.description_rounded,
        LegalDoc.privacy => Icons.shield_rounded,
        LegalDoc.disclaimer => Icons.info_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final data = LegalDocs.of(doc);
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.9;
    final bottomInset = media.viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.backgroundMain,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Grab handle ─────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: colors.borderDivider,
              borderRadius: BorderRadius.circular(99),
            ),
          ),

          // ── Header: icon + title + close ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    data.title,
                    style: context
                        .themed(AppTextStyles.h1, fontWeight: FontWeight.w700)
                        .copyWith(fontSize: 20, height: 1.15),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: colors.textSecondary,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.borderDivider),

          // ── Scrollable content ──────────────────────────────────────────
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              children: [
                _LastUpdatedBadge(lastUpdated: data.lastUpdated),
                const SizedBox(height: 16),
                Text(
                  data.intro,
                  style: context
                      .themed(AppTextStyles.s14, color: colors.textSecondary)
                      .copyWith(height: 1.7),
                ),
                const SizedBox(height: 24),
                ...data.sections.map((s) => LegalSectionCardWidget(section: s)),
              ],
            ),
          ),

          // ── Sticky footer CTA ───────────────────────────────────────────
          _Footer(bottomInset: bottomInset),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomInset),
      decoration: BoxDecoration(
        color: colors.backgroundMain,
        border: Border(top: BorderSide(color: colors.borderDivider)),
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: SizedBox(
            height: 52,
            child: Center(
              child: Text(
                'legal.btn_understand'.tr(),
                style: AppTextStyles.s15.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LastUpdatedBadge extends StatelessWidget {
  const _LastUpdatedBadge({required this.lastUpdated});

  final String lastUpdated;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.update_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'legal.last_updated'.tr(namedArgs: {'date': lastUpdated}),
              style: AppTextStyles.s12.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
