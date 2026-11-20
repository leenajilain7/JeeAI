import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/message.dart';
import 'inbox_state.dart';

class InboxController extends Notifier<InboxState> {
  var _localMessageSequence = 0;

  @override
  InboxState build() => InboxState.initial();

  /// Marks a conversation and its delivered incoming messages as read.
  bool markConversationRead(String conversationId) {
    final index = state.conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );
    if (index < 0) return false;

    final conversation = state.conversations[index];
    final updatedMessages = state.messagesFor(conversationId).map((message) {
      if (!message.isSentByMe &&
          message.messageStatus == MessageStatus.delivered) {
        return message.copyWith(messageStatus: MessageStatus.read);
      }
      return message;
    }).toList();

    final messagesByConversation = {
      ...state.messagesByConversation,
      conversationId: updatedMessages,
    };
    final conversations = [...state.conversations];
    conversations[index] = conversation.copyWith(unreadCount: 0);
    state = InboxState(
      conversations: conversations,
      messagesByConversation: messagesByConversation,
    );
    return true;
  }

  /// Adds a local sent message. Returns false for blank text or an unknown id.
  bool sendMessage({
    required String conversationId,
    required String content,
    DateTime? timestamp,
  }) {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) return false;

    final conversationIndex = state.conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );
    if (conversationIndex < 0) return false;

    final sentAt = timestamp ?? DateTime.now();
    final message = Message(
      id: 'local-${++_localMessageSequence}',
      conversationId: conversationId,
      content: trimmedContent,
      timestamp: sentAt,
      isSentByMe: true,
      messageStatus: MessageStatus.sent,
    );
    final history = [...state.messagesFor(conversationId), message];
    final messagesByConversation = {
      ...state.messagesByConversation,
      conversationId: history,
    };

    final conversations = [...state.conversations];
    conversations[conversationIndex] = conversations[conversationIndex]
        .copyWith(
          lastMessage: message,
          lastMessageTime: sentAt,
          unreadCount: 0,
        );
    state = InboxState(
      conversations: conversations,
      messagesByConversation: messagesByConversation,
    );
    return true;
  }
}
