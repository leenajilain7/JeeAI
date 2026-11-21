import 'api_enums.dart';
import 'json_parsing.dart';

/// Full message DTO returned by the conversation messages endpoints.
class MessageResponse {
  const MessageResponse({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.direction,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String conversationId;
  final String content;
  final ApiMessageDirection direction;
  final ApiMessageStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isSentByMe => direction == ApiMessageDirection.outgoing;

  factory MessageResponse.fromJson(JsonObject json) => MessageResponse(
    id: readRequiredString(json, 'id'),
    conversationId: readRequiredString(json, 'conversationId'),
    content: readRequiredString(json, 'content'),
    direction: ApiMessageDirection.fromJson(json['direction']),
    status: ApiMessageStatus.fromJson(json['status']),
    createdAt: readRequiredDateTime(json, 'createdAt'),
    updatedAt: readRequiredDateTime(json, 'updatedAt'),
  );

  JsonObject toJson() => {
    'id': id,
    'conversationId': conversationId,
    'content': content,
    'direction': direction.toJson(),
    'status': status.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
