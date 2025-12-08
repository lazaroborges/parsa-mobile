import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/api/serializers/tags_serializer.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/main.dart';

/// Service for tag API operations following the new RESTful backend.
///
/// Endpoints:
/// - POST /api/tags/ - Create tag
/// - PUT /api/tags/{id} - Update tag
/// - DELETE /api/tags/{id} - Delete tag
class PostUserTagService {
  static String get _baseEndpoint => '$apiEndpoint/api/tags/';

  static Map<String, String> _headers(String accessToken) => {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

  /// Creates a new tag via POST /api/tags/
  /// Returns the created tag with server-generated ID, or null on failure.
  static Future<ApiTag?> createTag(TagInDB tag, String accessToken) async {
    try {
      final Map<String, dynamic> tagJson = {
        'name': tag.name,
        'color': tag.color,
        'displayOrder': tag.displayOrder,
        'description': tag.description ?? '',
      };

      final response = await http.post(
        Uri.parse(_baseEndpoint),
        headers: _headers(accessToken),
        body: json.encode(tagJson),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        return ApiTag.fromJson(responseData);
      } else {
        print(
            'Failed to create tag. Status Code: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating tag: $e');
      return null;
    }
  }

  /// Updates an existing tag via PUT /api/tags/{id}
  /// Returns the updated tag, or null on failure.
  static Future<ApiTag?> updateTag(TagInDB tag, String accessToken) async {
    try {
      final Map<String, dynamic> tagJson = {
        'name': tag.name,
        'color': tag.color,
        'displayOrder': tag.displayOrder,
        'description': tag.description ?? '',
      };

      final response = await http.put(
        Uri.parse('$_baseEndpoint${tag.id}'),
        headers: _headers(accessToken),
        body: json.encode(tagJson),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        return ApiTag.fromJson(responseData);
      } else {
        print(
            'Failed to update tag. Status Code: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error updating tag: $e');
      return null;
    }
  }

  /// Deletes a tag via DELETE /api/tags/{id}
  /// Returns true on success (204 No Content), false otherwise.
  static Future<bool> deleteTag(String tagId, String accessToken) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseEndpoint$tagId'),
        headers: _headers(accessToken),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Failed to delete tag. Status Code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting tag: $e');
      return false;
    }
  }

  // Legacy methods for backward compatibility during migration
  @Deprecated('Use createTag or updateTag instead')
  static Future<bool> postUserTag(
      TagInDB tag, String accessToken, String? method) async {
    if (method == 'POST') {
      final result = await createTag(tag, accessToken);
      return result != null;
    } else {
      final result = await updateTag(tag, accessToken);
      return result != null;
    }
  }

  @Deprecated('Use deleteTag instead')
  static Future<bool> deleteUserTag(String tagId, String accessToken) async {
    return deleteTag(tagId, accessToken);
  }
}
