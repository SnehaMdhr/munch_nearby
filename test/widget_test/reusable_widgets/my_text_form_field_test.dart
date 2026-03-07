import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/features/auth/presentation/widgets/my_text_form_field.dart';

void main() {
  Widget buildWidget({
    required String label,
    ValueChanged<String>? onChanged,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    bool readOnly = false,
    String? Function(String?)? validator,
    TextEditingController? controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          child: MyTextFormField(
            label: label,
            onChanged: onChanged ?? (_) {},
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            obscureText: obscureText,
            readOnly: readOnly,
            validator: validator,
            controller: controller,
          ),
        ),
      ),
    );
  }

  // Test 1
  testWidgets('MyTextFormField displays the label', (tester) async {
    await tester.pumpWidget(buildWidget(label: 'Email'));
    expect(find.text('Email'), findsOneWidget);
  });

  // Test 2
  testWidgets('MyTextFormField calls onChanged when text changes', (
    tester,
  ) async {
    String changedValue = '';
    await tester.pumpWidget(
      buildWidget(label: 'Name', onChanged: (v) => changedValue = v),
    );
    await tester.enterText(find.byType(TextFormField), 'John');
    expect(changedValue, 'John');
  });

  // Test 3
  testWidgets('MyTextFormField displays prefix icon', (tester) async {
    await tester.pumpWidget(
      buildWidget(label: 'Email', prefixIcon: Icons.email_outlined),
    );
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
  });

  // Test 4
  testWidgets('MyTextFormField does not display prefix icon when null', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(label: 'Name'));
    expect(find.byType(Icon), findsNothing);
  });

  // Test 5
  testWidgets('MyTextFormField displays suffix icon', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        label: 'Password',
        suffixIcon: const Icon(Icons.visibility_off),
      ),
    );
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  // Test 6
  testWidgets('MyTextFormField shows default validation error when empty', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: MyTextFormField(label: 'Email', onChanged: (_) {}),
          ),
        ),
      ),
    );
    formKey.currentState!.validate();
    await tester.pump();
    expect(find.text('Please enter Email'), findsOneWidget);
  });

  // Test 7
  testWidgets('MyTextFormField uses custom validator', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: MyTextFormField(
              label: 'Email',
              onChanged: (_) {},
              validator: (v) => v!.isEmpty ? 'Custom error' : null,
            ),
          ),
        ),
      ),
    );
    formKey.currentState!.validate();
    await tester.pump();
    expect(find.text('Custom error'), findsOneWidget);
  });

  // Test 8
  testWidgets('MyTextFormField obscures text when obscureText is true', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(label: 'Password', obscureText: true));
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.obscureText, isTrue);
  });

  // Test 9
  testWidgets('MyTextFormField is editable when readOnly is false', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(label: 'Name'));
    await tester.enterText(find.byType(TextFormField), 'Test');
    expect(find.text('Test'), findsOneWidget);
  });

  // Test 10
  testWidgets('MyTextFormField uses provided controller', (tester) async {
    final controller = TextEditingController(text: 'initial');
    await tester.pumpWidget(buildWidget(label: 'Name', controller: controller));
    expect(find.text('initial'), findsOneWidget);
  });
}
