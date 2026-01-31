import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:munch_nearby/features/onboarding/presentation/pages/onboarding_screen2.dart';

void main() {
  testWidgets('MunchNearby onboarding screen #2', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen2()));

    expect(
      find.textContaining('Your reviews power our recommendations'),
      findsOneWidget,
    );
  });
}
