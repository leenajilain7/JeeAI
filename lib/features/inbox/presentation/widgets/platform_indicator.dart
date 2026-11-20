import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/messaging_platform.dart';

class PlatformIndicator extends StatelessWidget {
  const PlatformIndicator({
    required this.platform,
    this.compact = false,
    super.key,
  });

  final MessagingPlatform platform;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = switch (platform) {
      MessagingPlatform.whatsapp => const Color(0xFF39C982),
      MessagingPlatform.instagram => const Color(0xFFE879B8),
      MessagingPlatform.facebookMessenger => const Color(0xFF63A5FF),
    };
    final icon = switch (platform) {
      MessagingPlatform.whatsapp => Icons.chat_rounded,
      MessagingPlatform.instagram => Icons.camera_alt_rounded,
      MessagingPlatform.facebookMessenger => Icons.forum_rounded,
    };

    if (compact) {
      return Tooltip(
        message: platform.displayName,
        child: Icon(icon, size: 15, color: color),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            platform.displayName,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
