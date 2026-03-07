import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/favourite/presentation/widgets/favourite_sort_bar.dart';

void main() {
  Widget buildWidget({
    required String sortBy,
    required Function(String) onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: FavouriteSortBar(sortBy: sortBy, onChanged: onChanged),
      ),
    );
  }

  // Test 1
  testWidgets('FavouriteSortBar shows A-Z option', (tester) async {
    await tester.pumpWidget(buildWidget(sortBy: 'name', onChanged: (_) {}));
    expect(find.text('Sort: A-Z'), findsOneWidget);
  });

  // Test 2
  testWidgets('FavouriteSortBar shows dropdown', (tester) async {
    await tester.pumpWidget(buildWidget(sortBy: 'name', onChanged: (_) {}));
    expect(find.byType(DropdownButton<String>), findsOneWidget);
  });

  // Test 3
  testWidgets('FavouriteSortBar calls onChanged when value selected', (
    tester,
  ) async {
    String selectedValue = 'name';
    await tester.pumpWidget(
      buildWidget(sortBy: 'name', onChanged: (v) => selectedValue = v),
    );

    // Tap to open dropdown
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    // Select "Top Rated"
    await tester.tap(find.text('Sort: Top Rated').last);
    await tester.pumpAndSettle();

    expect(selectedValue, 'rating');
  });
}
