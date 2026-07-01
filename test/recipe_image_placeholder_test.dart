import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cravvy_cooking_app/common/widgets/images/recipe_image_placeholder.dart';

void main() {
  Widget host(Widget child, {double w = 200, double h = 150}) => MaterialApp(
        home: Scaffold(body: Center(child: SizedBox(width: w, height: h, child: child))),
      );

  testWidgets('hiện icon + tên khi đủ chỗ', (tester) async {
    await tester.pumpWidget(host(const RecipeImagePlaceholder(
      icon: Icons.lunch_dining,
      color: Color(0xFF2E7D4F),
      lightColor: Color(0xFFE6F2EC),
      name: 'Salad ức gà áp chảo sốt chanh dây',
    )));
    expect(find.byType(RecipeImagePlaceholder), findsOneWidget);
    expect(find.text('Salad ức gà áp chảo sốt chanh dây'), findsOneWidget);
    expect(find.byIcon(Icons.lunch_dining), findsWidgets); // icon nền + icon đĩa
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact: chỉ icon, không tên, không lỗi ở 90x90', (tester) async {
    await tester.pumpWidget(host(
      const RecipeImagePlaceholder(
        icon: Icons.free_breakfast,
        color: Color(0xFFC26A1B),
        lightColor: Color(0xFFFCEFE0),
        name: 'Không nên hiện',
        compact: true,
      ),
      w: 90,
      h: 90,
    ));
    expect(find.byType(RecipeImagePlaceholder), findsOneWidget);
    expect(find.text('Không nên hiện'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
