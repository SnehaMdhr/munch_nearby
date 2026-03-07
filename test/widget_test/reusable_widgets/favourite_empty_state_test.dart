import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/favourite/presentation/widgets/favourite_empty_state.dart';

void main() {
  Widget buildWidget() {
    return const MaterialApp(home: Scaffold(body: FavouriteEmptyState()));
  }

  // Test 1
  testWidgets('FavouriteEmptyState displays heart icon', (tester) async {
    await tester.pumpWidget(buildWidget());
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  // Test 2
  testWidgets('FavouriteEmptyState displays empty message', (tester) async {
    await tester.pumpWidget(buildWidget());
    expect(find.text('No favorites yet!'), findsOneWidget);
  });

  // Test 3
  testWidgets('FavouriteEmptyState heart icon has size 80', (tester) async {
    await tester.pumpWidget(buildWidget());
    final icon = tester.widget<Icon>(find.byIcon(Icons.favorite_border));
    expect(icon.size, 80);
  });
}
