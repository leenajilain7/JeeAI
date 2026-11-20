import 'package:flutter/material.dart';

import '../../../../shared/models/messaging_platform.dart';

class ConnectedPlatformsCard extends StatelessWidget {
  const ConnectedPlatformsCard({required this.platforms, super.key});

  final List<MessagingPlatform> platforms;

  @override
  Widget build(BuildContext context) {
    if (platforms.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No platforms are connected yet.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            for (var index = 0; index < platforms.length; index++) ...[
              if (index > 0) const Divider(height: 1, indent: 56, endIndent: 8),
              _PlatformItem(platform: platforms[index]),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlatformItem extends StatelessWidget {
  const _PlatformItem({required this.platform});

  final MessagingPlatform platform;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_platformIcon(platform), color: _platformColor(platform)),
      title: Text(platform.displayName),
      trailing: Text(
        'Demo',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

IconData _platformIcon(MessagingPlatform platform) => switch (platform) {
  MessagingPlatform.whatsapp => Icons.call_rounded,
  MessagingPlatform.instagram => Icons.camera_alt_rounded,
  MessagingPlatform.facebookMessenger => Icons.forum_rounded,
};

Color _platformColor(MessagingPlatform platform) => switch (platform) {
  MessagingPlatform.whatsapp => const Color(0xFF4ADE80),
  MessagingPlatform.instagram => const Color(0xFFE879F9),
  MessagingPlatform.facebookMessenger => const Color(0xFF60A5FA),
};
