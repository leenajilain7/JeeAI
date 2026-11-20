import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeeai/core/theme/app_theme.dart';
import 'package:jeeai/features/inbox/application/inbox_providers.dart';
import 'package:jeeai/features/inbox/presentation/screens/conversation_screen.dart';

void main() {
  testWidgets('conversation displays messages and locally sends a reply', (
    tester,
  ) async {
    final container = ProviderContainer.test();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: ConversationScreen(conversationId: 'conversation-ava'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ava Mitchell'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Hey! How has your week been?'), findsOneWidget);
    expect(find.text('Are we still on for coffee tomorrow?'), findsOneWidget);
    expect(
      container
          .read(inboxControllerProvider)
          .conversations
          .firstWhere((conversation) => conversation.id == 'conversation-ava')
          .unreadCount,
      0,
    );

    await tester.enterText(
      find.byKey(const Key('message-composer-field')),
      '  Sounds good!  ',
    );
    await tester.tap(find.byKey(const Key('send-message-button')));
    await tester.pumpAndSettle();

    expect(find.text('Sounds good!'), findsOneWidget);
    expect(
      container
          .read(inboxControllerProvider)
          .messagesFor('conversation-ava')
          .last
          .content,
      'Sounds good!',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('message-composer-field')))
          .controller
          ?.text,
      isEmpty,
    );
  });

  testWidgets('unknown conversation id has a clear empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: ConversationScreen(conversationId: 'missing'),
        ),
      ),
    );

    expect(find.text('Conversation not found'), findsOneWidget);
  });
}
