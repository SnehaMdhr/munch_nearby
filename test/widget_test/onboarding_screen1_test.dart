import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:munch_nearby/features/onboarding/presentation/pages/onboarding_screen1.dart';

void main() {
  testWidgets('MunchNearby onboarding screen #1', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen1()));

    expect(find.textContaining('Access full menus'), findsOneWidget);
  });
}
