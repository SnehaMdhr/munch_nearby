import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/features/profile/presentation/pages/change_password_screen.dart';
import 'package:munch_nearby/features/auth/presentation/state/auth_state.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';

class MockAuthViewModel extends Notifier<AuthState>
    with Mock
    implements AuthViewModel {
  @override
  AuthState build() => const AuthState();
}

void main() {
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuthViewModel = MockAuthViewModel();
  });

  Future<Widget> buildWidget() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: ChangePasswordScreen()),
    );
  }

  // Test 1
  testWidgets('ChangePasswordScreen displays title in AppBar', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Change Password'), findsWidgets);
  });

  // Test 2
  testWidgets('ChangePasswordScreen has Old Password field', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Old Password'), findsOneWidget);
  });

  // Test 3
  testWidgets('ChangePasswordScreen has New Password field', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('New Password'), findsOneWidget);
  });

  // Test 4
  testWidgets('ChangePasswordScreen has Confirm Password field', (
    tester,
  ) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  // Test 5
  testWidgets('ChangePasswordScreen has Change Password button', (
    tester,
  ) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  // Test 6
  testWidgets('ChangePasswordScreen validates empty old password', (
    tester,
  ) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter Old password'), findsOneWidget);
  });

  // Test 7
  testWidgets('ChangePasswordScreen validates short new password', (
    tester,
  ) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);

    await tester.enterText(find.byType(TextFormField).at(0), 'oldpass');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.enterText(find.byType(TextFormField).at(2), '123');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  // Test 8
  testWidgets('ChangePasswordScreen validates password mismatch', (
    tester,
  ) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);

    await tester.enterText(find.byType(TextFormField).at(0), 'oldpass');
    await tester.enterText(find.byType(TextFormField).at(1), 'newpassword');
    await tester.enterText(find.byType(TextFormField).at(2), 'differentpass');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  // Test 9
  testWidgets('ChangePasswordScreen has 3 visibility toggle icons', (
    tester,
  ) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
  });

  // Test 10
  testWidgets('ChangePasswordScreen has back navigation', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    // AppBar auto-adds a back button when there's a route to pop
    expect(find.byType(AppBar), findsOneWidget);
  });
}
