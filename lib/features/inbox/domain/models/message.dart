/// Delivery state for a locally stored or sent message.
enum MessageStatus { sending, sent, delivered, read, failed }

/// A single message belonging to a conversation.
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.timestamp,
    required this.isSentByMe,
    required this.messageStatus,
  }) : assert(id != ''),
       assert(conversationId != '');

  final String id;
  final String conversationId;
  final String content;
  final DateTime timestamp;
  final bool isSentByMe;
  final MessageStatus messageStatus;

  Message copyWith({
    String? id,
    String? conversationId,
    String? content,
    DateTime? timestamp,
    bool? isSentByMe,
    MessageStatus? messageStatus,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      messageStatus: messageStatus ?? this.messageStatus,
    );
  }
}
