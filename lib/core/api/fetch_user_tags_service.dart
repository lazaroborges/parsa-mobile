import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/database/services/tags/tags_service.dart';
import 'package:parsa/core/models/tags/tag.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';

import 'package:parsa/core/api/serializers/tags_serializer.dart';
import 'package:parsa/main.dart';

Future<void> fetchUserTags(BuildContext context) async {
  final auth0 = Auth0Provider.of(context)!.auth0;
  final credentials = await auth0.credentialsManager.credentials();

  // URL for fetching user tags
  String url = '$apiEndpoint/api/tags/';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer ${credentials.accessToken}',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // Sync the fetched tags with the local database
    await syncTags(response.body);

    var jsonResponse = json.decode(response.body);
    int objectCount = jsonResponse.length;
  } else {
    throw Exception('Failed to load user tags');
  }
}

Future<void> syncTags(String apiResponse) async {
  try {
    // Step 1: Parse the API response
    List<ApiTag> apiTags = fetchAndParseTags(apiResponse);
    if (apiTags.isEmpty) {
      print('No tags to sync.');
      return;
    }

    // Step 2: Convert API tags to local Tag model
    List<Tag> localTags = await convertTagsToLocal(apiTags);
    if (localTags.isEmpty) {
      print('No valid tags after conversion.');
      return;
    }

    // Step 3: Batch insert or update the tags in the local database
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

Future<List<Tag>> convertTagsToLocal(List<ApiTag> apiTags) async {
  List<Tag> localTags = [];

  for (final apiTag in apiTags) {
    try {
      // Create a local Tag instance from the API tag data
      Tag tag = Tag(
        id: apiTag.id,
        name: apiTag.name,
        color: apiTag.color ?? '#FFFFFF', // Default color if not provided
        description: apiTag.description ?? 'No description',
        displayOrder: apiTag.displayOrder ?? 0, // Default to 0 if not provided
      );

      localTags.add(tag);
    } catch (e) {
      print('Error processing tag ID: ${apiTag.id}: $e');
      // Continue processing other tags
      continue;
    }
  }

  return localTags;
}

Future<void> insertTagsIntoDB(List<Tag> tags) async {
  // Convert the list of `Tag` objects to `TagInDB` (the database representation of the tag)
  final List<TagInDB> tagsInDB = tags
      .map((tag) => TagInDB(
            id: tag.id,
            name: tag.name,
            color: tag.color,
            description: tag.description,
            displayOrder: tag.displayOrder,
          ))
      .toList();

  // Perform a batch insert or replace operation
  await TagService.instance.batchInsertOrReplaceTags(tagsInDB);
}
