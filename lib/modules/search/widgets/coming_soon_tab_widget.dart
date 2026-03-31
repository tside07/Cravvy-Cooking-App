import 'package:cravvy_cooking_app/init.dart';

class ComingSoonTabWidget extends StatelessWidget {
  const ComingSoonTabWidget({
    super.key,
    required this.icon,
    required this.label,
  });

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Coming soon in the next update',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
