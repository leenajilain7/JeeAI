import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    required this.pendingReplyCount,
    required this.onReviewReplies,
    super.key,
  });

  final int pendingReplyCount;
  final VoidCallback onReviewReplies;

  @override
  Widget build(BuildContext context) {
    final hasPendingReplies = pendingReplyCount > 0;

    return Card(
      color: AppColors.secondarySurface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                hasPendingReplies
                    ? Icons.mark_chat_unread_outlined
                    : Icons.mark_chat_read_outlined,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasPendingReplies
                        ? '$pendingReplyCount replies to review'
                        : 'You’re all caught up',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasPendingReplies
                        ? 'Your AI drafts are ready when you are.'
                        : 'There are no replies waiting for your review.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (hasPendingReplies) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Review replies in inbox',
                onPressed: onReviewReplies,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
