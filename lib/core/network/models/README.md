# Backend response models

These are transport DTOs for the JeeAI REST responses. They intentionally live
under `core/network/models/` and do not replace the existing inbox domain
models or mock data. A future repository can map these DTOs into the UI's
existing `Contact`, `Message`, and `Conversation` types.

## Response shapes

- `ContactResponse` matches `GET /contacts` and `GET /contacts/:id`: `id`,
  `name`, nullable `username` and `profileImage`, plus `createdAt` and
  `updatedAt`. The contact nested in a conversation omits timestamps, so those
  two fields are nullable.
- `MessageResponse` matches message list and create responses: `id`,
  `conversationId`, `content`, `direction`, `status`, `createdAt`, and
  `updatedAt`. `isSentByMe` is a convenience getter derived from `direction`;
  it is not an extra JSON field.
- `ConversationResponse` matches conversation list/detail responses: `id`,
  `platform`, nullable `lastMessageAt`, `unreadCount`, nested contact, and
  nullable `latestMessage`.
- `LatestMessagePreview` matches the compact message object nested in a
  conversation. The backend preview omits `conversationId` and `updatedAt`, so
  it is represented separately from the full message DTO.
- `PaginatedResponse<T>` matches list envelopes containing `data` and
  `pagination` (`page`, `limit`, `total`, `totalPages`). Supply a model parser
  when reading a generic envelope, for example:

  ```dart
  final contacts = PaginatedResponse<ContactResponse>.fromJson(
    json,
    itemFromJson: ContactResponse.fromJson,
  );
  ```

## Enum handling and dates

The backend serializes platform, direction, and status enum values in uppercase
(`WHATSAPP`, `OUTGOING`, `SENT`, and so on). `ApiPlatform`,
`ApiMessageDirection`, and `ApiMessageStatus` parse these values and map any
unrecognized value to `unknown`, so a newly added backend enum value does not
crash JSON parsing. Serializing that fallback writes `UNKNOWN`.

Date-time strings are parsed with `DateTime.tryParse` and invalid or missing
required fields throw `FormatException`. Nullable activity and nested contact
timestamps remain `null`. `toJson()` emits ISO 8601 timestamps and preserves
the response-specific field shape.
