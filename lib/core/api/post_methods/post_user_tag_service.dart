import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/models/tags/tag.dart';
import 'package:parsa/main.dart';

class PostUserTagService {
  static String get _apiEndpoint => '$apiEndpoint/api/insert-user-tags/';

  /// Serializes the [account] and sends it to the API.
  /// Returns [true] if the operation is successful (HTTP 200), otherwise [false].
  static Future<bool> postUserTag(
      TagInDB tag, String accessToken, String? method) async {
    try {
      // Serialize AccountInDB to JSON
      final Map<String, dynamic> tagJson = {
        'id': tag.id,
        'name': tag.name,
        'description': tag.description,
        'displayOrder': tag.displayOrder,
        'color': tag.color,
      };

      print('tagJson: $tagJson');

      // Send POST request to the API

      final response = method == 'POST'
          ? await http.post(
              Uri.parse(_apiEndpoint),
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
              },
              body: json.encode(tagJson),
            )
          : await http.put(
              Uri.parse(_apiEndpoint),
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
              },
              body: json.encode(tagJson),
            );

      print(
          'LA respuesta es la verdad ${response.body} ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
            'Failed to post account. Status Code: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error posting account: $e');
      return false;
    }
  }

  static Future<bool> deleteUserTag(String tagId, String accessToken) async {
    try {
      // Send DELETE request to the API

      final Map<String, dynamic> tagJson = {
        'id': tagId,
      };

      final response = await http.delete(
        Uri.parse(_apiEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(tagJson),
        // No body needed for DELETE request
      );

      print(
          'LA respuesta es la verdad ${response.body} ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 204 No Content for successful delete
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
}
