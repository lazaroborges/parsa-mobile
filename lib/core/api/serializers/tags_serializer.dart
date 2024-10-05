import 'package:json_annotation/json_annotation.dart';

part 'tags_serializer.g.dart';

/// Custom converter to handle the 'displayOrder' field, which may be null or missing.
class DisplayOrderConverter implements JsonConverter<int?, dynamic> {
  const DisplayOrderConverter();

  @override
  int? fromJson(dynamic json) {
    if (json == null) {
      return null;
    } else if (json is int) {
      return json;
    } else if (json is String) {
      return int.tryParse(json);
    } else {
      return null;
    }
  }

  @override
  dynamic toJson(int? object) => object;
}

@JsonSerializable()
class ApiTag {
  final String id; // Assuming the ID is required and always present
  final String name; // Assuming the name is required and always present

  final String? color; // Color might be null or missing
  final String? description; // Description might be null or missing

  @DisplayOrderConverter()
  @JsonKey(name: 'display_order')
  final int?
      displayOrder; // Use the custom converter to handle nulls or missing

  ApiTag({
    required this.id,
    required this.name,
    this.color,
    this.description,
    this.displayOrder,
  });

  /// Factory constructor for creating a new `ApiTag` instance from JSON.
  factory ApiTag.fromJson(Map<String, dynamic> json) => _$ApiTagFromJson(json);

  /// Converts the `ApiTag` instance to JSON.
  Map<String, dynamic> toJson() => _$ApiTagToJson(this);
}
