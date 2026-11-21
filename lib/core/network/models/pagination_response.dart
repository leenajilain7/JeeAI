import 'json_parsing.dart';

/// Pagination metadata used by contact, conversation, and message list APIs.
class PaginationMetadata {
  const PaginationMetadata({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory PaginationMetadata.fromJson(JsonObject json) => PaginationMetadata(
    page: readRequiredInt(json, 'page'),
    limit: readRequiredInt(json, 'limit'),
    total: readRequiredInt(json, 'total'),
    totalPages: readRequiredInt(json, 'totalPages'),
  );

  JsonObject toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'totalPages': totalPages,
  };
}

/// Common `{data, pagination}` envelope returned by list endpoints.
class PaginatedResponse<T> {
  const PaginatedResponse({required this.data, required this.pagination});

  final List<T> data;
  final PaginationMetadata pagination;

  factory PaginatedResponse.fromJson(
    JsonObject json, {
    required T Function(JsonObject json) itemFromJson,
  }) => PaginatedResponse<T>(
    data: readRequiredObjectList(json, 'data')
        .map(itemFromJson)
        .toList(growable: false),
    pagination: PaginationMetadata.fromJson(
      readRequiredObject(json, 'pagination'),
    ),
  );

  JsonObject toJson({required JsonObject Function(T item) itemToJson}) => {
    'data': data.map(itemToJson).toList(growable: false),
    'pagination': pagination.toJson(),
  };
}
