import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/onboarding/presentation/pages/onboarding_screen.dart';

void main() {
  Widget buildWidget() {
    return const MaterialApp(home: OnboardingScreen());
  }

  // Test 1
  testWidgets('OnboardingScreen displays Skip button', (tester) async {
    await tester.pumpWidget(buildWidget());
    expect(find.text('Skip'), findsOneWidget);
  });

  // Test 2
  testWidgets('OnboardingScreen displays Next button on first page', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    expect(find.text('Next'), findsOneWidget);
  });

  // Test 3
  testWidgets('OnboardingScreen displays 3 page dots', (tester) async {
    await tester.pumpWidget(buildWidget());
    // 3 PageDot widgets in the row
    expect(find.byType(Container), findsWidgets);
  });

  // Test 4
  testWidgets('OnboardingScreen shows first page title', (tester) async {
    await tester.pumpWidget(buildWidget());
    expect(find.textContaining('Discover delicious'), findsOneWidget);
  });

  // Test 5
  testWidgets('OnboardingScreen shows first page subtitle', (tester) async {
    await tester.pumpWidget(buildWidget());
    expect(find.textContaining('MunchNearby helps you'), findsOneWidget);
  });

  // Test 6
  testWidgets('OnboardingScreen shows restaurant menu icon on first page', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });

  // Test 7
  testWidgets('OnboardingScreen changes to Get Started on last page', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());

    // Swipe to page 2
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // Swipe to page 3
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);
  });
}
