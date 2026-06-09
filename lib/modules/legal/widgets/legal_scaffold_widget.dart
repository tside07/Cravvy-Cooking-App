import 'package:cravvy_cooking_app/init.dart';

import 'package:cravvy_cooking_app/modules/legal/models/legal_section.dart';

import 'package:easy_localization/easy_localization.dart';

import 'legal_section_card_widget.dart';



/// Reusable scaffold for all legal pages (Privacy Policy, Terms of Service,

/// Disclaimer). Provides a consistent layout with:

///  • back button + title header

///  • "Last updated" badge

///  • intro paragraph

///  • list of [LegalSection] cards

class LegalScaffoldWidget extends StatelessWidget {

  const LegalScaffoldWidget({

    super.key,

    required this.title,

    required this.lastUpdated,

    required this.intro,

    required this.sections,

  });



  final String title;

  final String lastUpdated;

  final String intro;

  final List<LegalSection> sections;



  @override

  Widget build(BuildContext context) {

    final colors = context.appColors;

    return Scaffold(

      body: SafeArea(

        child: Column(

          children: [

            // ── Header ──────────────────────────────────────────────────

            _LegalHeader(title: title),



            // ── Scrollable body ─────────────────────────────────────────

            Expanded(

              child: ListView(

                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),

                children: [

                  // Last updated badge

                  _LastUpdatedBadge(lastUpdated: lastUpdated),

                  const SizedBox(height: 16),



                  // Intro paragraph

                  Text(

                    intro,

                    style: context.themed(

                      AppTextStyles.s14,

                      color: colors.textSecondary,

                    ).copyWith(height: 1.65),

                  ),

                  const SizedBox(height: 24),



                  // Section cards

                  ...sections.map(

                    (s) => LegalSectionCardWidget(section: s),

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }

}



// ─── Private sub-widgets ──────────────────────────────────────────────────────



class _LegalHeader extends StatelessWidget {

  const _LegalHeader({required this.title});

  final String title;



  @override

  Widget build(BuildContext context) {

    final colors = context.appColors;

    return Container(

      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),

      decoration: BoxDecoration(

        color: colors.cardSurface,

        border: Border(

          bottom: BorderSide(color: colors.borderDivider),

        ),

      ),

      child: Row(

        children: [

          IconButton(

            icon: const Icon(Icons.arrow_back_ios_new_rounded),

            onPressed: () => context.pop(),

          ),

          Text(

            title,

            style: AppTextStyles.s18.copyWith(fontWeight: FontWeight.w700),

          ),

        ],

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

          color: AppColors.primaryLight,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),

        ),

        child: Row(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(

              Icons.update_rounded,

              size: 14,

              color: AppColors.primary,

            ),

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

