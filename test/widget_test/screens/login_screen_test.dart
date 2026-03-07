import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/features/auth/presentation/pages/login_screen.dart';
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

  Widget buildWidget() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
        sharedPreferencesProvider.overrideWith((ref) {
          throw UnimplementedError();
        }),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  Future<Widget> buildWidgetWithPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  // Test 1
  testWidgets('LoginScreen displays Welcome Back title', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Welcome'),
      ),
      findsOneWidget,
    );
  });

  // Test 2
  testWidgets('LoginScreen displays Login subtitle', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);
    expect(find.text('Login to your Account'), findsOneWidget);
  });

  // Test 3
  testWidgets('LoginScreen has email text field', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);
    expect(find.text('Email'), findsOneWidget);
  });

  // Test 4
  testWidgets('LoginScreen has password text field', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);
    expect(find.text('Password'), findsOneWidget);
  });

  // Test 5
  testWidgets('LoginScreen has Login button', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);
    expect(find.text('Login'), findsOneWidget);
  });

  // Test 6
  testWidgets('LoginScreen has Forgot Password link', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  // Test 7
  testWidgets('LoginScreen has Create Account link', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);
    expect(find.text('Create Account'), findsOneWidget);
  });

  // Test 8
  testWidgets('LoginScreen has Or sign in with divider', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);
    expect(find.text('Or sign in with'), findsOneWidget);
  });

  // Test 9
  testWidgets('LoginScreen validates empty email', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);

    await tester.ensureVisible(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
  });

  // Test 10
  testWidgets('LoginScreen validates empty password', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);

    // Enter email but not password
    await tester.enterText(
      find.byType(TextFormField).first,
      'test@example.com',
    );
    await tester.ensureVisible(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your password'), findsOneWidget);
  });

  // Test 11
  testWidgets('LoginScreen validates invalid email', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);

    await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
    await tester.ensureVisible(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  // Test 12
  testWidgets('LoginScreen validates short password', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.ensureVisible(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  // Test 13
  testWidgets('LoginScreen has password visibility toggle', (tester) async {
    final widget = await buildWidgetWithPrefs();
    await tester.pumpWidget(widget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
