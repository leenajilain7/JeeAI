import 'json_parsing.dart';

/// Contact DTO returned by GET /contacts and embedded in conversation results.
/// Timestamps are absent from the smaller embedded contact representation.
class ContactResponse {
  const ContactResponse({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? username;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ContactResponse.fromJson(JsonObject json) => ContactResponse(
    id: readRequiredString(json, 'id'),
    name: readRequiredString(json, 'name'),
    username: readNullableString(json, 'username'),
    profileImage: readNullableString(json, 'profileImage'),
    createdAt: readNullableDateTime(json, 'createdAt'),
    updatedAt: readNullableDateTime(json, 'updatedAt'),
  );

  JsonObject toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'profileImage': profileImage,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}
