import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munch_nearby/core/widgets/top_search_bar.dart';

void main() {
  Widget buildWidget() {
    return const MaterialApp(home: Scaffold(body: TopSearchBar()));
  }

  // Test 1
  testWidgets('TopSearchBar displays search hint text', (tester) async {
    await tester.pumpWidget(buildWidget());
    expect(find.text('Find a restaurant, dish, or cuisine...'), findsOneWidget);
  });

  // Test 2
  testWidgets('TopSearchBar contains a TextFormField', (tester) async {
    await tester.pumpWidget(buildWidget());
    expect(find.byType(TextFormField), findsOneWidget);
  });
}
