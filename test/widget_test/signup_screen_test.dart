import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/features/auth/presentation/pages/register_screen.dart';

import '../providers/mock_providers.dart';

void main() {
  testWidgets('SignupPage contains "Sign Up" text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(MockSharedPreferences()),
        ],
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Register'), findsOneWidget);
  });
}
