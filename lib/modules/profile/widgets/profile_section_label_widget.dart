import 'package:cravvy_cooking_app/init.dart';

class ProfileSectionLabelWidget extends SliverToBoxAdapter {
  ProfileSectionLabelWidget({super.key, required String label})
      : super(
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 4),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        );
}
