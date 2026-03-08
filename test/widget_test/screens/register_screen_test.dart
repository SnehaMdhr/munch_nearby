import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/features/auth/presentation/pages/register_screen.dart';
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
      child: const MaterialApp(home: RegisterScreen()),
    );
  }

  // Test 1
  testWidgets('RegisterScreen displays Sign Up title', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Sign'),
      ),
      findsOneWidget,
    );
  });

  // Test 2
  testWidgets('RegisterScreen displays subtitle', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Create your Account'), findsOneWidget);
  });

  // Test 3
  testWidgets('RegisterScreen has Name field', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Name'), findsOneWidget);
  });

  // Test 4
  testWidgets('RegisterScreen has Email field', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Email'), findsOneWidget);
  });

  // Test 5
  testWidgets('RegisterScreen has Password field', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Password'), findsOneWidget);
  });

  // Test 6
  testWidgets('RegisterScreen has Confirm Password field', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  // Test 7
  testWidgets('RegisterScreen has Register button', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Register'), findsOneWidget);
  });

  // Test 8
  testWidgets('RegisterScreen has Login link', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  // Test 9
  testWidgets('RegisterScreen validates empty name', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);

    await tester.ensureVisible(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your name'), findsOneWidget);
  });

  // Test 10
  testWidgets('RegisterScreen validates invalid email', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);

    // Enter name
    await tester.enterText(find.byType(TextFormField).at(0), 'John');
    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).at(1), 'notanemail');

    await tester.ensureVisible(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email'), findsOneWidget);
  });

  // Test 11
  testWidgets('RegisterScreen validates password mismatch', (tester) async {
    final widget = await buildWidget();
    await tester.pumpWidget(widget);

    await tester.enterText(find.byType(TextFormField).at(0), 'John');
    await tester.enterText(find.byType(TextFormField).at(1), 'test@mail.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'different123');

    await tester.ensureVisible(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
