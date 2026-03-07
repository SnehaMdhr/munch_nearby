import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/tab_button.dart';

void main() {
  Widget buildWidget({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    Color activeColor = const Color(0xFFE98869),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            TabButton(
              title: title,
              isActive: isActive,
              onTap: onTap,
              activeColor: activeColor,
            ),
          ],
        ),
      ),
    );
  }

  // Test 1
  testWidgets('TabButton displays title text', (tester) async {
    await tester.pumpWidget(
      buildWidget(title: 'Menu', isActive: false, onTap: () {}),
    );
    expect(find.text('Menu'), findsOneWidget);
  });

  // Test 2
  testWidgets('TabButton calls onTap when tapped', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      buildWidget(
        title: 'Reviews',
        isActive: false,
        onTap: () => tapped = true,
      ),
    );
    await tester.tap(find.text('Reviews'));
    expect(tapped, isTrue);
  });

  // Test 3
  testWidgets('Active TabButton shows white text', (tester) async {
    await tester.pumpWidget(
      buildWidget(title: 'Menu', isActive: true, onTap: () {}),
    );
    final text = tester.widget<Text>(find.text('Menu'));
    expect(text.style!.color, Colors.white);
  });

  // Test 4
  testWidgets('Inactive TabButton shows grey text', (tester) async {
    await tester.pumpWidget(
      buildWidget(title: 'Menu', isActive: false, onTap: () {}),
    );
    final text = tester.widget<Text>(find.text('Menu'));
    expect(text.style!.color, Colors.grey.shade500);
  });
}
