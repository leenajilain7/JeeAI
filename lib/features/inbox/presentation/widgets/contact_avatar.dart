import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/models/contact.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({required this.contact, this.radius = 25, super.key});

  final Contact contact;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final imageUrl = contact.profileImage;
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withValues(alpha: 0.22),
        child: Text(
          _initials(contact.name),
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.secondarySurface,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              _initials(contact.name),
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    return name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }
}
