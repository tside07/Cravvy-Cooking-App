import 'package:flutter/material.dart';
import 'package:cravvy_cooking_app/core/theme/app_colors.dart';

class IngredientInputBar extends StatelessWidget {
  const IngredientInputBar({
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
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(52, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: EdgeInsets.zero,
          ),
          child: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
