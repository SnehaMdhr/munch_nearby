import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/favourite_toggle_button.dart';

void main() {
  Widget buildWidget({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color backgroundColor = Colors.white,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: FavouriteToggleButton(
          icon: icon,
          onTap: onTap,
          iconColor: iconColor,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }

  // Test 1
  testWidgets('FavouriteToggleButton displays the given icon', (tester) async {
    await tester.pumpWidget(buildWidget(icon: Icons.favorite, onTap: () {}));
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  // Test 2
  testWidgets('FavouriteToggleButton calls onTap when tapped', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      buildWidget(icon: Icons.favorite_border, onTap: () => tapped = true),
    );
    await tester.tap(find.byType(GestureDetector));
    expect(tapped, isTrue);
  });

  // Test 3
  testWidgets('FavouriteToggleButton uses custom icon color', (tester) async {
    await tester.pumpWidget(
      buildWidget(icon: Icons.favorite, onTap: () {}, iconColor: Colors.red),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
    expect(icon.color, Colors.red);
  });
}
