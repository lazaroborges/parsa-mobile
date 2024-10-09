import 'package:drift/drift.dart';
import 'package:parsa/core/api/post_methods/post_user_account.dart';
import 'package:parsa/core/api/post_methods/post_user_tag_service.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/models/tags/tag.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';

class TagService {
  final AppDB db;

  TagService._(this.db);
  static final TagService instance = TagService._(AppDB.instance);

  Future<int> insertTag(TagInDB tag) async {
    try {
      // Retrieve the access token from your authentication service

      final auth0 = getAuth0Instance();

      // Retrieve the access token from the Auth0 instance
      final credentials = await auth0.credentialsManager.credentials();
      // Post the account to the API
      bool isPosted = await PostUserTagService.postUserTag(
          tag, credentials.accessToken, 'POST');

      if (!isPosted) {
        throw Exception('Failed to post account to the API.');
      } else {
        return await db
            .into(db.tags)
            .insert(tag, mode: InsertMode.insertOrReplace);
      }
    } catch (e) {
      print('Error inserting account: $e');
      rethrow; // Propagate the error to be handled upstream if needed
    }
  }

  Future<bool> updateTag(TagInDB tag) async {
    try {
      // Retrieve the access token from your authentication service

      final auth0 = getAuth0Instance();

      // Retrieve the access token from the Auth0 instance
      final credentials = await auth0.credentialsManager.credentials();
      // Post the account to the API
      bool isPut = await PostUserTagService.postUserTag(
          tag, credentials.accessToken, 'PUT');

      if (!isPut) {
        throw Exception('Failed to post account to the API.');
      } else {
        return db.update(db.tags).replace(tag);
      }
    } catch (e) {
      print('Error updating account: $e');
      rethrow; // Propagate the error to be handled upstream if needed
    }
  }

  Future<int> deleteTag(String tagId) async {
    try {
      // Added missing try block
      final auth0 = getAuth0Instance();

      // Retrieve the access token from the Auth0 instance
      final credentials = await auth0.credentialsManager.credentials();
      // Post the account to the API
      bool isPut = await PostUserTagService.deleteUserTag(
          tagId, credentials.accessToken);

      if (!isPut) {
        throw Exception('Failed to post account to the API.');
      } else {
        return (db.delete(db.tags)..where((tbl) => tbl.id.equals(tagId))).go();
      } // Added missing closing bracket
    } catch (e) {
      print('Error updating account: $e');
      rethrow; // Propagate the error to be handled upstream if needed
    }
  }

  // Batch insert or replace tags
  Future<void> batchInsertOrReplaceTags(List<TagInDB> tags) async {
    await db.batch((batch) {
      // Insert each tag in the batch
      for (var tag in tags) {
        batch.insert(
          db.tags, // The table to insert into
          tag, // The data to insert
          mode: InsertMode.insertOrReplace, // Insert or replace mode
        );
      }
    });
  }

  Future<int> insertTagFromAPI(TagInDB tag) {
    return db.into(db.tags).insert(tag); // Single insert method
  }

  Stream<TagInDB?> getTagById(String tagId) {
    return (db.select(db.tags)..where((tbl) => tbl.id.equals(tagId)))
        .watchSingleOrNull();
  }

  Stream<List<Tag>> getTags({
    Expression<bool> Function(Tags)? filter,
    int? limit,
    int? offset,
  }) {
    limit ??= -1;

    return (db.select(db.tags)
          ..where(filter ?? (tbl) => const CustomExpression('(TRUE)'))
          ..orderBy([(acc) => OrderingTerm.asc(acc.displayOrder)])
          ..limit(limit, offset: offset))
        .watch()
        .map(
          (event) => event.map((e) => Tag.fromTagInDB(e)).toList(),
        );
  }
}
