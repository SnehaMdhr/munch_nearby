import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/features/auth/presentation/pages/forget_password_screen.dart';
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
      child: const MaterialApp(home: ForgetPasswordScreen()),
    );
  }

  // Test 1
  testWidgets('ForgetPasswordScreen displays Password Reset title', (
    tester,
  ) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Password') &&
            w.text.toPlainText().contains('Reset'),
      ),
      findsOneWidget,
    );
  });

  // Test 2
  testWidgets('ForgetPasswordScreen has Email field initially', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Email'), findsOneWidget);
  });

  // Test 3
  testWidgets('ForgetPasswordScreen has Send OTP button initially', (
    tester,
  ) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Send OTP'), findsOneWidget);
  });

  // Test 4
  testWidgets('ForgetPasswordScreen has Login link', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Remembered Password?'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  // Test 5
  testWidgets('ForgetPasswordScreen validates empty email', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);

    await tester.tap(find.text('Send OTP'));
    await tester.pump();

    expect(find.text('Enter your EMail'), findsOneWidget);
  });

  // Test 6
  testWidgets('ForgetPasswordScreen has email icon', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
  });
}
