import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeeai/features/inbox/data/mock_inbox_data.dart';
import 'package:jeeai/shared/models/conversation.dart';
import 'package:jeeai/shared/models/messaging_platform.dart';
import 'package:jeeai/main.dart';

void main() {
  test('conversation initials are derived from the contact name', () {
    const conversation = Conversation(
      contactName: 'Ava Mitchell',
      lastMessage: 'See you soon!',
      platform: MessagingPlatform.whatsapp,
      timeLabel: '10:42 AM',
      avatarColorValue: 0xFF355E55,
    );

    expect(conversation.initials, 'AM');
  });

  test('mock data includes the requested messaging platforms', () {
    expect(
      MockInboxData.connectedPlatforms.map((platform) => platform.displayName),
      containsAll(['WhatsApp', 'Instagram', 'Facebook Messenger']),
    );
    expect(MockInboxData.conversations, isNotEmpty);
  });

  testWidgets('dashboard displays mock data and navigation changes tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: JeeAiApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('3 replies to review'), findsOneWidget);
    expect(find.text('Ava Mitchell'), findsOneWidget);
    expect(find.text('3 platforms'), findsOneWidget);

    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();
    expect(find.text('All your conversations, together.'), findsOneWidget);
    expect(find.text('Ava Mitchell'), findsOneWidget);

    await tester.tap(find.text('Ava Mitchell'));
    await tester.pumpAndSettle();
    expect(find.text('Are we still on for coffee tomorrow?'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to inbox'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
