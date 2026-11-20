import '../../../../shared/models/messaging_platform.dart';
import 'contact.dart';
import 'message.dart';

/// Inbox conversation data, separate from the dashboard's preview model.
class Conversation {
  const Conversation({
    required this.id,
    required this.contact,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.platform,
    this.unreadCount = 0,
  }) : assert(id != ''),
       assert(unreadCount >= 0);

  final String id;
  final Contact contact;
  final Message lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final MessagingPlatform platform;

  Conversation copyWith({
    String? id,
    Contact? contact,
    Message? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    MessagingPlatform? platform,
  }) {
    return Conversation(
      id: id ?? this.id,
      contact: contact ?? this.contact,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      platform: platform ?? this.platform,
    );
  }
}
