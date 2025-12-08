import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/tags/tags_service.dart';
import 'package:parsa/core/models/tags/tag.dart';
import 'package:parsa/core/services/auth/backend_auth_service.dart';
import 'package:parsa/core/api/serializers/tags_serializer.dart';
import 'package:parsa/main.dart';

/// Fetches all tags for the authenticated user from GET /api/tags/
/// Tags are ordered by displayOrder ascending, then name ascending.
Future<void> fetchUserTags(BuildContext context) async {
    final backendAuthService = BackendAuthService.instance;
    final token = backendAuthService.token;

  String url = '$apiEndpoint/api/tags/';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=utf-8',
    },
  );

  if (response.statusCode == 200) {
    final String decodedBody = utf8.decode(response.bodyBytes);
    await syncTags(decodedBody);
  } else {
    throw Exception('Failed to load user tags');
  }
}

Future<void> syncTags(String apiResponse) async {
  try {
    List<ApiTag> apiTags = fetchAndParseTags(apiResponse);
    if (apiTags.isEmpty) {
      print('No tags to sync.');
      return;
    }

    List<Tag> localTags = convertTagsToLocal(apiTags);
    if (localTags.isEmpty) {
      print('No valid tags after conversion.');
      return;
    }

    await insertTagsIntoDB(localTags);
    print('Tags synced successfully.');
  } catch (e) {
    print('Error syncing tags: $e');
  }
}

List<ApiTag> fetchAndParseTags(String responseBody) {
  try {
    final List<dynamic> parsed = json.decode(responseBody);
    return parsed.map((json) => ApiTag.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Error parsing tags: $e');
  }
}

/// Converts API tags to local Tag model.
/// New backend returns all fields as required (non-null).
List<Tag> convertTagsToLocal(List<ApiTag> apiTags) {
  List<Tag> localTags = [];

  for (final apiTag in apiTags) {
    try {
      Tag tag = Tag(
        id: apiTag.id,
        name: apiTag.name,
        color: apiTag.color,
        description: apiTag.description,
        displayOrder: apiTag.displayOrder,
      );
      localTags.add(tag);
    } catch (e) {
      print('Error processing tag ID: ${apiTag.id}: $e');
      continue;
    }
  }

  return localTags;
}

Future<void> insertTagsIntoDB(List<Tag> tags) async {
  final List<TagInDB> tagsInDB = tags
      .map((tag) => TagInDB(
            id: tag.id,
            name: tag.name,
            color: tag.color,
            description: tag.description,
            displayOrder: tag.displayOrder,
          ))
      .toList();

  await TagService.instance.batchInsertOrReplaceTags(tagsInDB);
}
