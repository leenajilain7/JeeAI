import 'api_enums.dart';
import 'contact_response.dart';
import 'json_parsing.dart';
import 'latest_message_preview.dart';

/// Conversation summary/detail DTO returned by the backend.
class ConversationResponse {
  const ConversationResponse({
    required this.id,
    required this.platform,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.contact,
    required this.latestMessage,
  });

  final String id;
  final ApiPlatform platform;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final ContactResponse contact;
  final LatestMessagePreview? latestMessage;

  factory ConversationResponse.fromJson(JsonObject json) {
    final rawPreview = readNullableObject(json, 'latestMessage');
    return ConversationResponse(
      id: readRequiredString(json, 'id'),
      platform: ApiPlatform.fromJson(json['platform']),
      lastMessageAt: readNullableDateTime(json, 'lastMessageAt'),
      unreadCount: readRequiredInt(json, 'unreadCount'),
      contact: ContactResponse.fromJson(readRequiredObject(json, 'contact')),
      latestMessage: rawPreview == null
          ? null
          : LatestMessagePreview.fromJson(rawPreview),
    );
  }

  JsonObject toJson() => {
    'id': id,
    'platform': platform.toJson(),
    'lastMessageAt': lastMessageAt?.toIso8601String(),
    'unreadCount': unreadCount,
    'contact': contact.toJson(),
    'latestMessage': latestMessage?.toJson(),
  };
}
