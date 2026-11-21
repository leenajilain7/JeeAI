typedef JsonObject = Map<String, dynamic>;

String readRequiredString(JsonObject json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('Expected a string for "$key".');
}

String? readNullableString(JsonObject json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('Expected a string or null for "$key".');
}

int readRequiredInt(JsonObject json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num && value == value.toInt()) return value.toInt();
  throw FormatException('Expected an integer for "$key".');
}

DateTime readRequiredDateTime(JsonObject json, String key) {
  final value = readRequiredString(json, key);
  final result = DateTime.tryParse(value);
  if (result == null) throw FormatException('Expected an ISO 8601 date for "$key".');
  return result;
}

DateTime? readNullableDateTime(JsonObject json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Expected an ISO 8601 date or null for "$key".');
  }
  final result = DateTime.tryParse(value);
  if (result == null) throw FormatException('Expected an ISO 8601 date for "$key".');
  return result;
}

JsonObject readRequiredObject(JsonObject json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Expected an object for "$key".');
}

JsonObject? readNullableObject(JsonObject json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Expected an object or null for "$key".');
}

List<JsonObject> readRequiredObjectList(JsonObject json, String key) {
  final value = json[key];
  if (value is! List) throw FormatException('Expected a list for "$key".');
  return value.map((item) {
    if (item is Map<String, dynamic>) return item;
    throw FormatException('Expected every item in "$key" to be an object.');
  }).toList(growable: false);
}
