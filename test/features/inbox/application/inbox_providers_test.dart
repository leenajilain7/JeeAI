import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeeai/features/inbox/application/inbox_providers.dart';
import 'package:jeeai/features/inbox/domain/models/message.dart';
import 'package:jeeai/shared/models/messaging_platform.dart';

void main() {
  test('search matches contact names without case sensitivity', () {
    final container = ProviderContainer.test();
    container.read(searchQueryProvider.notifier).setQuery('aVa');

    final results = container.read(filteredConversationsProvider);

    expect(results.map((conversation) => conversation.id), [
      'conversation-ava',
    ]);
  });

  test(
    'search matches message content and returns an empty result when absent',
    () {
      final container = ProviderContainer.test();
      container.read(searchQueryProvider.notifier).setQuery('coffee');

      expect(
        container
            .read(filteredConversationsProvider)
            .map((conversation) => conversation.id),
        ['conversation-ava'],
      );

      container.read(searchQueryProvider.notifier).setQuery('no matching text');
      expect(container.read(filteredConversationsProvider), isEmpty);
    },
  );

  test('platform filter shows only matching conversations', () {
    final container = ProviderContainer.test();
    container
        .read(selectedPlatformFilterProvider.notifier)
        .select(MessagingPlatform.instagram);

    expect(
      container
          .read(filteredConversationsProvider)
          .map((conversation) => conversation.id),
      containsAll(['conversation-jordan', 'conversation-sofia']),
    );
    expect(
      container
          .read(filteredConversationsProvider)
          .every(
            (conversation) =>
                conversation.platform == MessagingPlatform.instagram,
          ),
      isTrue,
    );
  });

  test('conversations are sorted by most recent activity', () {
    final container = ProviderContainer.test();

    expect(
      container
          .read(filteredConversationsProvider)
          .map((conversation) => conversation.id)
          .take(3),
      ['conversation-ava', 'conversation-jordan', 'conversation-maya'],
    );
  });

  test('sending trims text and updates message history and preview', () {
    final container = ProviderContainer.test();
    final controller = container.read(inboxControllerProvider.notifier);
    final sentAt = DateTime(2026, 11, 20, 11);

    final sent = controller.sendMessage(
      conversationId: 'conversation-ava',
      content: '  See you soon!  ',
      timestamp: sentAt,
    );
    final state = container.read(inboxControllerProvider);
    final conversation = state.conversations.firstWhere(
      (item) => item.id == 'conversation-ava',
    );
    final latestMessage = state.messagesFor('conversation-ava').last;

    expect(sent, isTrue);
    expect(latestMessage.content, 'See you soon!');
    expect(latestMessage.isSentByMe, isTrue);
    expect(latestMessage.messageStatus, MessageStatus.sent);
    expect(conversation.lastMessage.id, latestMessage.id);
    expect(conversation.lastMessageTime, sentAt);
    expect(conversation.unreadCount, 0);
  });

  test('sending rejects blank content and invalid conversation ids', () {
    final container = ProviderContainer.test();
    final controller = container.read(inboxControllerProvider.notifier);

    expect(
      controller.sendMessage(
        conversationId: 'conversation-ava',
        content: '   ',
      ),
      isFalse,
    );
    expect(
      controller.sendMessage(conversationId: 'missing', content: 'Hello'),
      isFalse,
    );
  });

  test(
    'opening a conversation clears unread count and marks received messages',
    () {
      final container = ProviderContainer.test();
      final controller = container.read(inboxControllerProvider.notifier);

      expect(controller.markConversationRead('conversation-ava'), isTrue);

      final state = container.read(inboxControllerProvider);
      final conversation = state.conversations.firstWhere(
        (item) => item.id == 'conversation-ava',
      );
      final receivedMessages = state
          .messagesFor('conversation-ava')
          .where((message) => !message.isSentByMe);

      expect(conversation.unreadCount, 0);
      expect(
        receivedMessages.every(
          (message) => message.messageStatus == MessageStatus.read,
        ),
        isTrue,
      );
      expect(controller.markConversationRead('missing'), isFalse);
    },
  );
}
