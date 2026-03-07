import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/onboarding/presentation/widgets/page_dot.dart';

void main() {
  Widget buildWidget({required bool active}) {
    return MaterialApp(
      home: Scaffold(body: PageDot(active: active)),
    );
  }

  // Test 1
  testWidgets('PageDot renders as a Container', (tester) async {
    await tester.pumpWidget(buildWidget(active: true));
    expect(find.byType(Container), findsWidgets);
  });

  // Test 2
  testWidgets('Active PageDot has brand color', (tester) async {
    await tester.pumpWidget(buildWidget(active: true));
    final container = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) {
          final dec = c.decoration;
          if (dec is BoxDecoration) return dec.shape == BoxShape.circle;
          return false;
        })
        .first;
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, const Color(0xFFE87A5D));
  });

  // Test 3
  testWidgets('Inactive PageDot has grey color', (tester) async {
    await tester.pumpWidget(buildWidget(active: false));
    final container = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) {
          final dec = c.decoration;
          if (dec is BoxDecoration) return dec.shape == BoxShape.circle;
          return false;
        })
        .first;
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.grey.shade300);
  });
}
