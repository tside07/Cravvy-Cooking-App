import 'package:cravvy_cooking_app/init.dart';
import 'package:cravvy_cooking_app/modules/auth/otp/widgets/otp_box_widget.dart';

class OtpInputRowWidget extends StatelessWidget {
  const OtpInputRowWidget({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(controllers.length, (i) {
        return OtpBoxWidget(
          controller: controllers[i],
          focusNode: focusNodes[i],
          onChanged: (v) {
            if (v.isNotEmpty && i < controllers.length - 1) {
              FocusScope.of(context).requestFocus(focusNodes[i + 1]);
            } else if (v.isEmpty && i > 0) {
              FocusScope.of(context).requestFocus(focusNodes[i - 1]);
            }
            onChanged(v);
          },
        );
      }),
    );
  }
}
