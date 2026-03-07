import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/auth/presentation/widgets/my_button.dart';

void main() {
  Widget buildWidget({
    required String text,
    VoidCallback? onPressed,
    bool loading = false,
    Icon? icon,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MyButton(
          text: text,
          onPressed: onPressed,
          loading: loading,
          icon: icon,
        ),
      ),
    );
  }

  // Test 1
  testWidgets('MyButton displays the given text', (tester) async {
    await tester.pumpWidget(buildWidget(text: 'Login', onPressed: () {}));
    expect(find.text('Login'), findsOneWidget);
  });

  // Test 2
  testWidgets('MyButton triggers onPressed callback when tapped', (
    tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      buildWidget(text: 'Submit', onPressed: () => tapped = true),
    );
    await tester.tap(find.byType(ElevatedButton));
    expect(tapped, isTrue);
  });

  // Test 3
  testWidgets('MyButton does not trigger callback when onPressed is null', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(text: 'Disabled', onPressed: null));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  // Test 4
  testWidgets('MyButton shows CircularProgressIndicator when loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildWidget(text: 'Loading...', onPressed: () {}, loading: true),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // Test 5
  testWidgets(
    'MyButton does not show CircularProgressIndicator when not loading',
    (tester) async {
      await tester.pumpWidget(buildWidget(text: 'Click', onPressed: () {}));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  // Test 6
  testWidgets('MyButton has reduced opacity when disabled', (tester) async {
    await tester.pumpWidget(buildWidget(text: 'Disabled', onPressed: null));
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 0.5);
  });

  // Test 7
  testWidgets('MyButton has full opacity when enabled', (tester) async {
    await tester.pumpWidget(buildWidget(text: 'Enabled', onPressed: () {}));
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1.0);
  });

  // Test 8
  testWidgets('MyButton displays icon when provided', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        text: 'With Icon',
        onPressed: () {},
        icon: const Icon(Icons.login),
      ),
    );
    expect(find.byIcon(Icons.login), findsOneWidget);
  });

  // Test 9
  testWidgets('MyButton does not display icon when not provided', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(text: 'No Icon', onPressed: () {}));
    expect(find.byType(Icon), findsNothing);
  });

  // Test 10
  testWidgets('MyButton is disabled when loading is true', (tester) async {
    await tester.pumpWidget(
      buildWidget(text: 'Loading', onPressed: () {}, loading: true),
    );
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
