import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/core/widgets/profile_item.dart';

void main() {
  Widget buildWidget({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ProfileItem(icon: icon, title: title, onTap: onTap),
      ),
    );
  }

  // Test 1
  testWidgets('ProfileItem displays the title', (tester) async {
    await tester.pumpWidget(
      buildWidget(icon: Icons.person, title: 'Edit Profile', onTap: () {}),
    );
    expect(find.text('Edit Profile'), findsOneWidget);
  });

  // Test 2
  testWidgets('ProfileItem displays the icon', (tester) async {
    await tester.pumpWidget(
      buildWidget(icon: Icons.lock, title: 'Change Password', onTap: () {}),
    );
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  // Test 3
  testWidgets('ProfileItem displays forward arrow', (tester) async {
    await tester.pumpWidget(
      buildWidget(icon: Icons.person, title: 'Settings', onTap: () {}),
    );
    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
  });

  // Test 4
  testWidgets('ProfileItem calls onTap when tapped', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      buildWidget(
        icon: Icons.logout,
        title: 'Logout',
        onTap: () => tapped = true,
      ),
    );
    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });
}
