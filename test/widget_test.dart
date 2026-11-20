// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jeeai/main.dart';

void main() {
  testWidgets('Bottom navigation changes the active destination', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: JeeAiApp()));
    await tester.pumpAndSettle();

    expect(
      find.text('Your messages and assistant activity will appear here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('Your conversations will appear here.'), findsOneWidget);
  });
}
