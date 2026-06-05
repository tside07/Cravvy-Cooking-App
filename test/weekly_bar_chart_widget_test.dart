import 'package:cravvy_cooking_app/modules/progress/widgets/weekly_bar_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('all-zero weekly data does not produce NaN bar heights', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeeklyBarChartWidget(
            data: [0, 0, 0, 0, 0, 0, 0],
            days: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
            goal: 2000,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final containers = tester.widgetList<Container>(find.byType(Container));
    for (final container in containers) {
      final h = container.constraints?.maxHeight;
      if (h != null) {
        expect(h.isNaN, isFalse, reason: 'bar height must not be NaN');
      }
    }
  });
}
