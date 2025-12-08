import 'package:json_annotation/json_annotation.dart';

part 'tags_serializer.g.dart';

/// API Tag model matching the new Go backend response format.
/// Response fields are camelCase (id, name, color, displayOrder, description)
@JsonSerializable()
class ApiTag {
  final String id;
  final String name;
  final String color;
  final int displayOrder;
  final String description;

  ApiTag({
    required this.id,
    required this.name,
    required this.color,
    required this.displayOrder,
    required this.description,
  });

  /// Factory constructor for creating a new `ApiTag` instance from JSON.
  factory ApiTag.fromJson(Map<String, dynamic> json) => _$ApiTagFromJson(json);

  /// Converts the `ApiTag` instance to JSON (for POST/PUT requests).
  /// Note: id is excluded for create requests, but included for update requests.
  Map<String, dynamic> toJson() => _$ApiTagToJson(this);

  /// Creates JSON for POST request (excludes id)
  Map<String, dynamic> toCreateJson() => {
        'name': name,
        'color': color,
        'displayOrder': displayOrder,
        'description': description,
      };

  /// Creates JSON for PUT request (excludes id since it's in the URL path)
  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'color': color,
        'displayOrder': displayOrder,
        'description': description,
      };
}
