import '../data/mock_conversation_data.dart';
import '../domain/models/conversation.dart';
import '../domain/models/message.dart';

/// Immutable data backing the inbox's conversations and message histories.
class InboxState {
  InboxState({
    required List<Conversation> conversations,
    required Map<String, List<Message>> messagesByConversation,
  }) : conversations = List.unmodifiable(conversations),
       messagesByConversation = Map.unmodifiable({
         for (final entry in messagesByConversation.entries)
           entry.key: List<Message>.unmodifiable(entry.value),
       });

  factory InboxState.initial() {
    return InboxState(
      conversations: MockConversationData.conversations,
      messagesByConversation: MockConversationData.messagesByConversation,
    );
  }

  final List<Conversation> conversations;
  final Map<String, List<Message>> messagesByConversation;

  List<Message> messagesFor(String conversationId) {
    return messagesByConversation[conversationId] ?? const [];
  }
}
