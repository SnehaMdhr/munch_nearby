import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/onboarding/presentation/widgets/build_page.dart';

void main() {
  Widget buildWidget({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BuildPage(icon: icon, title: title, subtitle: subtitle),
      ),
    );
  }

  // Test 1
  testWidgets('BuildPage displays the icon', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        icon: Icons.restaurant_menu,
        title: 'Discover',
        subtitle: 'Find food',
      ),
    );
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });

  // Test 2
  testWidgets('BuildPage displays the title text', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        icon: Icons.restaurant_menu,
        title: 'Discover delicious food',
        subtitle: 'Subtitle here',
      ),
    );
    expect(find.text('Discover delicious food'), findsOneWidget);
  });

  // Test 3
  testWidgets('BuildPage displays the subtitle text', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        icon: Icons.map_outlined,
        title: 'Explore',
        subtitle: 'Find local restaurants near you',
      ),
    );
    expect(find.text('Find local restaurants near you'), findsOneWidget);
  });

  // Test 4
  testWidgets('BuildPage icon has correct color', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        icon: Icons.star_border,
        title: 'Rate',
        subtitle: 'Rate your experience',
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.star_border));
    expect(icon.color, const Color(0xFFE87A5D));
  });

  // Test 5
  testWidgets('BuildPage icon has size 90', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        icon: Icons.star_border,
        title: 'Rate',
        subtitle: 'Rate your experience',
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.star_border));
    expect(icon.size, 90);
  });
}
