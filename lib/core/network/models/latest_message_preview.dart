import 'api_enums.dart';
import 'json_parsing.dart';

/// The compact `latestMessage` object embedded in a conversation response.
class LatestMessagePreview {
  const LatestMessagePreview({
    required this.id,
    required this.content,
    required this.direction,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String content;
  final ApiMessageDirection direction;
  final ApiMessageStatus status;
  final DateTime createdAt;

  factory LatestMessagePreview.fromJson(JsonObject json) =>
      LatestMessagePreview(
        id: readRequiredString(json, 'id'),
        content: readRequiredString(json, 'content'),
        direction: ApiMessageDirection.fromJson(json['direction']),
        status: ApiMessageStatus.fromJson(json['status']),
        createdAt: readRequiredDateTime(json, 'createdAt'),
      );

  JsonObject toJson() => {
    'id': id,
    'content': content,
    'direction': direction.toJson(),
    'status': status.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };
}
