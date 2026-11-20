import 'package:flutter_test/flutter_test.dart';
import 'package:jeeai/features/inbox/domain/models/contact.dart';
import 'package:jeeai/features/inbox/domain/models/conversation.dart';
import 'package:jeeai/features/inbox/domain/models/message.dart';
import 'package:jeeai/shared/models/messaging_platform.dart';

void main() {
  final timestamp = DateTime(2026, 11, 20, 10, 42);

  test('contact stores optional profile image and username', () {
    const contact = Contact(
      id: 'contact-1',
      name: 'Ava Mitchell',
      platform: MessagingPlatform.whatsapp,
    );

    expect(contact.id, 'contact-1');
    expect(contact.name, 'Ava Mitchell');
    expect(contact.platform, MessagingPlatform.whatsapp);
    expect(contact.profileImage, isNull);
    expect(contact.username, isNull);
  });

  test('message stores sender, timestamp and delivery status', () {
    final message = Message(
      id: 'message-1',
      conversationId: 'conversation-1',
      content: 'See you tomorrow!',
      timestamp: timestamp,
      isSentByMe: false,
      messageStatus: MessageStatus.delivered,
    );

    expect(message.timestamp, timestamp);
    expect(message.isSentByMe, isFalse);
    expect(message.messageStatus, MessageStatus.delivered);
  });

  test('message copyWith changes status while retaining other values', () {
    final message = Message(
      id: 'message-1',
      conversationId: 'conversation-1',
      content: 'Hello',
      timestamp: timestamp,
      isSentByMe: true,
      messageStatus: MessageStatus.sending,
    );

    final sentMessage = message.copyWith(messageStatus: MessageStatus.sent);

    expect(sentMessage.messageStatus, MessageStatus.sent);
    expect(sentMessage.content, message.content);
    expect(sentMessage.timestamp, message.timestamp);
  });

  test('conversation links contact and last message', () {
    const contact = Contact(
      id: 'contact-1',
      name: 'Ava Mitchell',
      platform: MessagingPlatform.whatsapp,
    );
    final message = Message(
      id: 'message-1',
      conversationId: 'conversation-1',
      content: 'Are we still on for coffee tomorrow?',
      timestamp: timestamp,
      isSentByMe: false,
      messageStatus: MessageStatus.read,
    );
    final conversation = Conversation(
      id: 'conversation-1',
      contact: contact,
      lastMessage: message,
      lastMessageTime: timestamp,
      unreadCount: 2,
      platform: MessagingPlatform.whatsapp,
    );

    expect(conversation.contact, same(contact));
    expect(conversation.lastMessage, same(message));
    expect(conversation.lastMessageTime, timestamp);
    expect(conversation.unreadCount, 2);
  });
}
