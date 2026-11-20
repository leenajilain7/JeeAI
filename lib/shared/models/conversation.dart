import 'messaging_platform.dart';

class Conversation {
  const Conversation({
    required this.contactName,
    required this.lastMessage,
    required this.platform,
    required this.timeLabel,
    required this.avatarColorValue,
    this.unreadCount = 0,
  });

  final String contactName;
  final String lastMessage;
  final MessagingPlatform platform;
  final String timeLabel;
  final int avatarColorValue;
  final int unreadCount;

  String get initials => contactName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}
