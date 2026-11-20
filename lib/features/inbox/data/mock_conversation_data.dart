import '../../../shared/models/messaging_platform.dart';
import '../domain/models/contact.dart';
import '../domain/models/conversation.dart';
import '../domain/models/message.dart';

/// Local sample data used by the unified inbox and conversation screens.
///
/// The fixture is intentionally static: it does not connect to any messaging
/// service and can be replaced by a repository implementation later.
abstract final class MockConversationData {
  static final Message _avaLastMessage = Message(
    id: 'message-ava-3',
    conversationId: 'conversation-ava',
    content: 'Are we still on for coffee tomorrow?',
    timestamp: DateTime(2026, 11, 20, 10, 42),
    isSentByMe: false,
    messageStatus: MessageStatus.delivered,
  );

  static final Message _jordanLastMessage = Message(
    id: 'message-jordan-3',
    conversationId: 'conversation-jordan',
    content: 'Loved the photos from the weekend!',
    timestamp: DateTime(2026, 11, 20, 9, 18),
    isSentByMe: true,
    messageStatus: MessageStatus.read,
  );

  static final Message _noahLastMessage = Message(
    id: 'message-noah-3',
    conversationId: 'conversation-noah',
    content: 'Thanks, that sounds great.',
    timestamp: DateTime(2026, 11, 19, 19, 25),
    isSentByMe: false,
    messageStatus: MessageStatus.delivered,
  );

  static final Message _mayaLastMessage = Message(
    id: 'message-maya-3',
    conversationId: 'conversation-maya',
    content: 'I will send you the details tonight.',
    timestamp: DateTime(2026, 11, 19, 20, 5),
    isSentByMe: false,
    messageStatus: MessageStatus.read,
  );

  static final Message _sofiaLastMessage = Message(
    id: 'message-sofia-3',
    conversationId: 'conversation-sofia',
    content: 'Just sent you the link—let me know what you think.',
    timestamp: DateTime(2026, 11, 19, 17, 50),
    isSentByMe: false,
    messageStatus: MessageStatus.delivered,
  );

  static final Message _ethanLastMessage = Message(
    id: 'message-ethan-3',
    conversationId: 'conversation-ethan',
    content: 'Perfect, see you there!',
    timestamp: DateTime(2026, 11, 18, 13, 12),
    isSentByMe: true,
    messageStatus: MessageStatus.read,
  );

  static final List<Conversation> conversations = List.unmodifiable([
    Conversation(
      id: 'conversation-ava',
      contact: Contact(
        id: 'contact-ava',
        name: 'Ava Mitchell',
        platform: MessagingPlatform.whatsapp,
        username: 'ava.mitchell',
      ),
      lastMessage: _avaLastMessage,
      lastMessageTime: DateTime(2026, 11, 20, 10, 42),
      unreadCount: 2,
      platform: MessagingPlatform.whatsapp,
    ),
    Conversation(
      id: 'conversation-jordan',
      contact: Contact(
        id: 'contact-jordan',
        name: 'Jordan Lee',
        platform: MessagingPlatform.instagram,
        username: 'jordanlee',
      ),
      lastMessage: _jordanLastMessage,
      lastMessageTime: DateTime(2026, 11, 20, 9, 18),
      platform: MessagingPlatform.instagram,
    ),
    Conversation(
      id: 'conversation-noah',
      contact: Contact(
        id: 'contact-noah',
        name: 'Noah Patel',
        platform: MessagingPlatform.facebookMessenger,
        username: 'noah.patel.7',
      ),
      lastMessage: _noahLastMessage,
      lastMessageTime: DateTime(2026, 11, 19, 19, 25),
      unreadCount: 1,
      platform: MessagingPlatform.facebookMessenger,
    ),
    Conversation(
      id: 'conversation-maya',
      contact: Contact(
        id: 'contact-maya',
        name: 'Maya Chen',
        platform: MessagingPlatform.whatsapp,
        username: 'mayachen',
      ),
      lastMessage: _mayaLastMessage,
      lastMessageTime: DateTime(2026, 11, 19, 20, 5),
      platform: MessagingPlatform.whatsapp,
    ),
    Conversation(
      id: 'conversation-sofia',
      contact: Contact(
        id: 'contact-sofia',
        name: 'Sofia Reyes',
        platform: MessagingPlatform.instagram,
        username: 'sofia.reyes',
      ),
      lastMessage: _sofiaLastMessage,
      lastMessageTime: DateTime(2026, 11, 19, 17, 50),
      unreadCount: 3,
      platform: MessagingPlatform.instagram,
    ),
    Conversation(
      id: 'conversation-ethan',
      contact: Contact(
        id: 'contact-ethan',
        name: 'Ethan Brooks',
        platform: MessagingPlatform.facebookMessenger,
        username: 'ethan.brooks',
      ),
      lastMessage: _ethanLastMessage,
      lastMessageTime: DateTime(2026, 11, 18, 13, 12),
      platform: MessagingPlatform.facebookMessenger,
    ),
  ]);

  /// Sample message histories for the conversation screen.
  /// Lists are ordered oldest to newest.
  static final Map<String, List<Message>> messagesByConversation =
      Map.unmodifiable({
        'conversation-ava': List<Message>.unmodifiable([
          Message(
            id: 'message-ava-1',
            conversationId: 'conversation-ava',
            content: 'Hey! How has your week been?',
            timestamp: DateTime(2026, 11, 20, 10, 31),
            isSentByMe: false,
            messageStatus: MessageStatus.read,
          ),
          Message(
            id: 'message-ava-2',
            conversationId: 'conversation-ava',
            content: 'Pretty good. Want to catch up tomorrow?',
            timestamp: DateTime(2026, 11, 20, 10, 36),
            isSentByMe: true,
            messageStatus: MessageStatus.read,
          ),
          _avaLastMessage,
        ]),
        'conversation-jordan': List<Message>.unmodifiable([
          Message(
            id: 'message-jordan-1',
            conversationId: 'conversation-jordan',
            content: 'Did you get a chance to look at the album?',
            timestamp: DateTime(2026, 11, 20, 9, 2),
            isSentByMe: false,
            messageStatus: MessageStatus.read,
          ),
          Message(
            id: 'message-jordan-2',
            conversationId: 'conversation-jordan',
            content: 'I did—so many great shots!',
            timestamp: DateTime(2026, 11, 20, 9, 12),
            isSentByMe: true,
            messageStatus: MessageStatus.read,
          ),
          _jordanLastMessage,
        ]),
        'conversation-noah': List<Message>.unmodifiable([
          Message(
            id: 'message-noah-1',
            conversationId: 'conversation-noah',
            content: 'Are you free to review the plan later?',
            timestamp: DateTime(2026, 11, 19, 19, 4),
            isSentByMe: false,
            messageStatus: MessageStatus.read,
          ),
          Message(
            id: 'message-noah-2',
            conversationId: 'conversation-noah',
            content: 'Sure, I can take a look after dinner.',
            timestamp: DateTime(2026, 11, 19, 19, 12),
            isSentByMe: true,
            messageStatus: MessageStatus.read,
          ),
          _noahLastMessage,
        ]),
        'conversation-maya': List<Message>.unmodifiable([
          Message(
            id: 'message-maya-1',
            conversationId: 'conversation-maya',
            content: 'I found the notes from our call.',
            timestamp: DateTime(2026, 11, 19, 19, 44),
            isSentByMe: true,
            messageStatus: MessageStatus.read,
          ),
          Message(
            id: 'message-maya-2',
            conversationId: 'conversation-maya',
            content: 'Great, could you send them when you get a chance?',
            timestamp: DateTime(2026, 11, 19, 19, 52),
            isSentByMe: false,
            messageStatus: MessageStatus.read,
          ),
          _mayaLastMessage,
        ]),
        'conversation-sofia': List<Message>.unmodifiable([
          Message(
            id: 'message-sofia-1',
            conversationId: 'conversation-sofia',
            content: 'I put together a few ideas for the campaign.',
            timestamp: DateTime(2026, 11, 19, 17, 20),
            isSentByMe: true,
            messageStatus: MessageStatus.read,
          ),
          Message(
            id: 'message-sofia-2',
            conversationId: 'conversation-sofia',
            content: 'These look promising. Do you have a link?',
            timestamp: DateTime(2026, 11, 19, 17, 34),
            isSentByMe: false,
            messageStatus: MessageStatus.read,
          ),
          _sofiaLastMessage,
        ]),
        'conversation-ethan': List<Message>.unmodifiable([
          Message(
            id: 'message-ethan-1',
            conversationId: 'conversation-ethan',
            content: 'Want to meet at the new place on Friday?',
            timestamp: DateTime(2026, 11, 18, 12, 48),
            isSentByMe: false,
            messageStatus: MessageStatus.read,
          ),
          Message(
            id: 'message-ethan-2',
            conversationId: 'conversation-ethan',
            content: 'That works for me.',
            timestamp: DateTime(2026, 11, 18, 13, 2),
            isSentByMe: true,
            messageStatus: MessageStatus.read,
          ),
          _ethanLastMessage,
        ]),
      });
}
