import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:munch_nearby/features/onboarding/presentation/pages/onboarding_screen.dart';

void main() {
  testWidgets('MunchNearby onboarding screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    expect(
      find.textContaining(
        'MunchNearby helps you easily find the best local restaurants',
      ),
      findsOneWidget,
    );
  });
}
