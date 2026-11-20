import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeeai/core/theme/app_theme.dart';
import 'package:jeeai/features/inbox/presentation/screens/inbox_screen.dart';

void main() {
  testWidgets(
    'inbox shows conversations and searches contact and message text',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(body: InboxScreen()),
          ),
        ),
      );

      expect(find.text('Ava Mitchell'), findsOneWidget);
      expect(find.text('Jordan Lee'), findsOneWidget);
      expect(find.text('Noah Patel'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('inbox-search-field')),
        'coffee',
      );
      await tester.pumpAndSettle();
      expect(find.text('Ava Mitchell'), findsOneWidget);
      expect(find.text('Jordan Lee'), findsNothing);

      await tester.enterText(
        find.byKey(const Key('inbox-search-field')),
        'nothing matches this',
      );
      await tester.pumpAndSettle();
      expect(find.text('No conversations found'), findsOneWidget);
    },
  );

  testWidgets('platform chips filter the conversation list', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: InboxScreen()),
        ),
      ),
    );

    await tester.tap(find.text('Instagram'));
    await tester.pumpAndSettle();

    expect(find.text('Jordan Lee'), findsOneWidget);
    expect(find.text('Sofia Reyes'), findsOneWidget);
    expect(find.text('Ava Mitchell'), findsNothing);
  });
}
