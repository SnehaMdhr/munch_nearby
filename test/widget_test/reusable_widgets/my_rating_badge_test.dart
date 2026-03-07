import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/my_rating_badge.dart';

void main() {
  Widget buildWidget({required int rating}) {
    return MaterialApp(
      home: Scaffold(body: MyRatingBadge(rating: rating)),
    );
  }

  // Test 1
  testWidgets('MyRatingBadge renders 5 star icons', (tester) async {
    await tester.pumpWidget(buildWidget(rating: 3));
    final icons = tester.widgetList<Icon>(find.byType(Icon));
    expect(icons.length, 5);
  });

  // Test 2
  testWidgets('MyRatingBadge renders correct filled stars for rating 5', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(rating: 5));
    expect(find.byIcon(Icons.star), findsNWidgets(5));
    expect(find.byIcon(Icons.star_border), findsNothing);
  });

  // Test 3
  testWidgets('MyRatingBadge renders correct filled stars for rating 0', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(rating: 0));
    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.byIcon(Icons.star_border), findsNWidgets(5));
  });

  // Test 4
  testWidgets('MyRatingBadge renders 3 filled and 2 empty for rating 3', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(rating: 3));
    expect(find.byIcon(Icons.star), findsNWidgets(3));
    expect(find.byIcon(Icons.star_border), findsNWidgets(2));
  });
}
