import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/review_action_button.dart';

void main() {
  Widget buildWidget({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    double iconSize = 20,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ReviewActionButtons(
          onEdit: onEdit,
          onDelete: onDelete,
          iconSize: iconSize,
        ),
      ),
    );
  }

  // Test 1
  testWidgets('ReviewActionButtons displays edit and delete icons', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(onEdit: () {}, onDelete: () {}));
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  // Test 2
  testWidgets('ReviewActionButtons calls onEdit when edit tapped', (
    tester,
  ) async {
    bool edited = false;
    await tester.pumpWidget(
      buildWidget(onEdit: () => edited = true, onDelete: () {}),
    );
    await tester.tap(find.byIcon(Icons.edit_outlined));
    expect(edited, isTrue);
  });

  // Test 3
  testWidgets('ReviewActionButtons calls onDelete when delete tapped', (
    tester,
  ) async {
    bool deleted = false;
    await tester.pumpWidget(
      buildWidget(onEdit: () {}, onDelete: () => deleted = true),
    );
    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(deleted, isTrue);
  });

  // Test 4
  testWidgets('ReviewActionButtons edit icon has blue color', (tester) async {
    await tester.pumpWidget(buildWidget(onEdit: () {}, onDelete: () {}));
    final icon = tester.widget<Icon>(find.byIcon(Icons.edit_outlined));
    expect(icon.color, Colors.blue);
  });

  // Test 5
  testWidgets('ReviewActionButtons delete icon has red color', (tester) async {
    await tester.pumpWidget(buildWidget(onEdit: () {}, onDelete: () {}));
    final icon = tester.widget<Icon>(find.byIcon(Icons.delete_outline));
    expect(icon.color, Colors.red);
  });
}
