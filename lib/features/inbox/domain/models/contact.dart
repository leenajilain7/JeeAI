import '../../../../shared/models/messaging_platform.dart';

/// A person participating in a messaging conversation.
class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.platform,
    this.profileImage,
    this.username,
  }) : assert(id != ''),
       assert(name != '');

  final String id;
  final String name;
  final String? profileImage;
  final MessagingPlatform platform;
  final String? username;
}
