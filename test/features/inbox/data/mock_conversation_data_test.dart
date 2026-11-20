import 'package:flutter_test/flutter_test.dart';
import 'package:jeeai/features/inbox/data/mock_conversation_data.dart';
import 'package:jeeai/shared/models/messaging_platform.dart';

void main() {
  test('mock conversations cover all connected messaging platforms', () {
    final platforms = MockConversationData.conversations
        .map((conversation) => conversation.platform)
        .toSet();

    expect(
      platforms,
      containsAll({
        MessagingPlatform.whatsapp,
        MessagingPlatform.instagram,
        MessagingPlatform.facebookMessenger,
      }),
    );
  });

  test('mock conversation and message histories are linked consistently', () {
    expect(MockConversationData.conversations, isNotEmpty);

    for (final conversation in MockConversationData.conversations) {
      final messages =
          MockConversationData.messagesByConversation[conversation.id];

      expect(messages, isNotNull, reason: conversation.id);
      expect(messages, isNotEmpty, reason: conversation.id);
      expect(messages!.last.id, conversation.lastMessage.id);
      expect(messages.last.conversationId, conversation.id);
      expect(conversation.contact.platform, conversation.platform);
      expect(conversation.unreadCount, greaterThanOrEqualTo(0));
    }
  });

  test('mock data includes names, previews, timestamps and unread counts', () {
    final avaConversation = MockConversationData.conversations.first;

    expect(avaConversation.contact.name, 'Ava Mitchell');
    expect(
      avaConversation.lastMessage.content,
      'Are we still on for coffee tomorrow?',
    );
    expect(avaConversation.lastMessageTime, DateTime(2026, 11, 20, 10, 42));
    expect(avaConversation.unreadCount, 2);
  });
}
