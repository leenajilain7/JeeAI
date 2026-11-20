import '../../../shared/models/conversation.dart';
import '../../../shared/models/messaging_platform.dart';

abstract final class MockInboxData {
  static const int pendingAiReplyCount = 3;

  static const List<MessagingPlatform> connectedPlatforms = [
    MessagingPlatform.whatsapp,
    MessagingPlatform.instagram,
    MessagingPlatform.facebookMessenger,
  ];

  static const List<Conversation> conversations = [
    Conversation(
      contactName: 'Ava Mitchell',
      lastMessage: 'Are we still on for coffee tomorrow?',
      platform: MessagingPlatform.whatsapp,
      timeLabel: '10:42 AM',
      unreadCount: 2,
      avatarColorValue: 0xFF355E55,
    ),
    Conversation(
      contactName: 'Jordan Lee',
      lastMessage: 'Loved the photos from the weekend!',
      platform: MessagingPlatform.instagram,
      timeLabel: '9:18 AM',
      avatarColorValue: 0xFF65477B,
    ),
    Conversation(
      contactName: 'Noah Patel',
      lastMessage: 'Thanks, that sounds great.',
      platform: MessagingPlatform.facebookMessenger,
      timeLabel: 'Yesterday',
      unreadCount: 1,
      avatarColorValue: 0xFF345B83,
    ),
    Conversation(
      contactName: 'Maya Chen',
      lastMessage: 'I will send you the details tonight.',
      platform: MessagingPlatform.whatsapp,
      timeLabel: 'Yesterday',
      avatarColorValue: 0xFF765738,
    ),
  ];
}
