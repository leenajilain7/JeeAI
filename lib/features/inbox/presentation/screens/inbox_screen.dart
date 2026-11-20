import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/messaging_platform.dart';
import '../../application/inbox_providers.dart';
import '../../domain/models/conversation.dart';
import '../widgets/conversation_tile.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(filteredConversationsProvider);
    final hasConversations = ref.watch(
      inboxControllerProvider.select((state) => state.conversations.isNotEmpty),
    );

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inbox',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'All your conversations, together.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  key: const Key('inbox-search-field'),
                  onChanged: ref.read(searchQueryProvider.notifier).setQuery,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search people or messages',
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: Icon(Icons.tune_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                _PlatformFilters(
                  selected: ref.watch(selectedPlatformFilterProvider),
                  onSelected: (platform) => ref
                      .read(selectedPlatformFilterProvider.notifier)
                      .select(platform),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: !hasConversations
                      ? const _EmptyState(
                          icon: Icons.forum_outlined,
                          title: 'Your inbox is quiet',
                          message: 'New conversations will show up here.',
                        )
                      : conversations.isEmpty
                      ? const _EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No conversations found',
                          message: 'Try another name or message.',
                        )
                      : _ConversationList(conversations: conversations),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlatformFilters extends StatelessWidget {
  const _PlatformFilters({required this.selected, required this.onSelected});

  final MessagingPlatform? selected;
  final ValueChanged<MessagingPlatform?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: selected == null,
            onSelected: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          for (final platform in MessagingPlatform.values) ...[
            _FilterChip(
              label: platform.displayName,
              selected: selected == platform,
              onSelected: () =>
                  onSelected(selected == platform ? null : platform),
            ),
            if (platform != MessagingPlatform.values.last)
              const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.conversations});

  final List<Conversation> conversations;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('conversation-list'),
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      itemCount: conversations.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 70, endIndent: 8),
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ConversationTile(
          conversation: conversation,
          onTap: () => context.push('/inbox/${conversation.id}'),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.secondary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
