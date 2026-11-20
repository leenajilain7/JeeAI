import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/messaging_platform.dart';
import '../domain/models/conversation.dart';
import 'inbox_controller.dart';
import 'inbox_state.dart';

final inboxControllerProvider = NotifierProvider<InboxController, InboxState>(
  InboxController.new,
);

final searchQueryProvider = NotifierProvider<SearchQueryController, String>(
  SearchQueryController.new,
);

final selectedPlatformFilterProvider =
    NotifierProvider<SelectedPlatformFilterController, MessagingPlatform?>(
      SelectedPlatformFilterController.new,
    );

/// Applies search and platform selection, then presents newest activity first.
final filteredConversationsProvider = Provider<List<Conversation>>((ref) {
  final conversations = ref.watch(
    inboxControllerProvider.select((state) => state.conversations),
  );
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final platform = ref.watch(selectedPlatformFilterProvider);

  final filtered = conversations.where((conversation) {
    final matchesPlatform =
        platform == null || conversation.platform == platform;
    final matchesQuery =
        query.isEmpty ||
        conversation.contact.name.toLowerCase().contains(query) ||
        conversation.lastMessage.content.toLowerCase().contains(query);

    return matchesPlatform && matchesQuery;
  }).toList()..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

  return List.unmodifiable(filtered);
});

class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

class SelectedPlatformFilterController extends Notifier<MessagingPlatform?> {
  @override
  MessagingPlatform? build() => null;

  void select(MessagingPlatform? platform) {
    state = platform;
  }
}
