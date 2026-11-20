import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../inbox/data/mock_inbox_data.dart';
import '../widgets/connected_platforms_card.dart';
import '../widgets/conversation_preview_tile.dart';
import '../widgets/dashboard_summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DashboardHeader(),
                const SizedBox(height: 32),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your conversations, all in one place.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 24),
                DashboardSummaryCard(
                  pendingReplyCount: MockInboxData.pendingAiReplyCount,
                  onReviewReplies: () => context.go('/inbox'),
                ),
                const SizedBox(height: 28),
                _SectionHeading(
                  title: 'Connected platforms',
                  actionLabel:
                      '${MockInboxData.connectedPlatforms.length} platforms',
                ),
                const SizedBox(height: 12),
                const ConnectedPlatformsCard(
                  platforms: MockInboxData.connectedPlatforms,
                ),
                const SizedBox(height: 28),
                _SectionHeading(
                  title: 'Recent conversations',
                  actionLabel: 'View inbox',
                  onAction: () => context.go('/inbox'),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      if (MockInboxData.conversations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No recent conversations yet.'),
                        )
                      else
                        for (
                          var index = 0;
                          index < MockInboxData.conversations.length &&
                              index < 2;
                          index++
                        ) ...[
                          if (index > 0)
                            const Divider(height: 1, indent: 72, endIndent: 16),
                          ConversationPreviewTile(
                            conversation: MockInboxData.conversations[index],
                            onTap: () => context.go('/inbox'),
                          ),
                        ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _AssistantShortcut(onTap: () => context.go('/assistant')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'JeeAI',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        IconButton.filledTonal(
          tooltip: 'Profile',
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.person_outline_rounded),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (onAction == null)
          Text(actionLabel, style: Theme.of(context).textTheme.bodySmall)
        else
          TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _AssistantShortcut extends StatelessWidget {
  const _AssistantShortcut({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondarySurface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.secondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need a hand replying?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Draft a thoughtful response with JeeAI.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Open AI Assistant',
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
