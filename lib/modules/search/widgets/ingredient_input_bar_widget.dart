import 'package:cravvy_cooking_app/init.dart';

class IngredientInputBarWidget extends StatelessWidget {
  const IngredientInputBarWidget({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  final TextEditingController controller;
  final ValueChanged<String> onAdd;

  void _submit() {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      onAdd(text);
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Type an ingredient...',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.textHint),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        AppGap.w10,
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(52, 52),
            shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.a14),
            padding: EdgeInsets.zero,
          ),
          child: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
