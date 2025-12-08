import 'package:drift/drift.dart';
import 'package:parsa/core/api/post_methods/post_user_tag_service.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/models/tags/tag.dart';
import 'package:parsa/core/services/auth/backend_auth_service.dart';

class TagService {
  final AppDB db;

  TagService._(this.db);
  static final TagService instance = TagService._(AppDB.instance);

  /// Creates a new tag via POST /api/tags/
  /// The server generates the UUID, so we use the returned ID for local storage.
  Future<TagInDB> insertTag(TagInDB tag) async {
    try {
      final backendAuthService = BackendAuthService.instance;
      final token = backendAuthService.token;

      final apiTag =
          await PostUserTagService.createTag(tag, token ?? '');

      if (apiTag == null) {
        throw Exception('Failed to create tag on the API.');
      }

      // Use the server-generated ID
      final tagWithServerId = TagInDB(
        id: apiTag.id,
        name: apiTag.name,
        color: apiTag.color,
        description: apiTag.description,
        displayOrder: apiTag.displayOrder,
      );

      await db
          .into(db.tags)
          .insert(tagWithServerId, mode: InsertMode.insertOrReplace);

      return tagWithServerId;
    } catch (e) {
      print('Error inserting tag: $e');
      rethrow;
    }
  }

  /// Updates an existing tag via PUT /api/tags/{id}
  Future<bool> updateTag(TagInDB tag) async {
    try {
      final backendAuthService = BackendAuthService.instance;
      final token = backendAuthService.token;

      final apiTag =
          await PostUserTagService.updateTag(tag, token ?? '');

      if (apiTag == null) {
        throw Exception('Failed to update tag on the API.');
      }

      // Update local DB with the response data
      final updatedTag = TagInDB(
        id: apiTag.id,
        name: apiTag.name,
        color: apiTag.color,
        description: apiTag.description,
        displayOrder: apiTag.displayOrder,
      );

      return db.update(db.tags).replace(updatedTag);
    } catch (e) {
      print('Error updating tag: $e');
      rethrow;
    }
  }

  /// Deletes a tag via DELETE /api/tags/{id}
  Future<int> deleteTag(String tagId) async {
    try {
      final backendAuthService = BackendAuthService.instance;
      final token = backendAuthService.token;

      bool isDeleted =
          await PostUserTagService.deleteTag(tagId, token ?? '');

      if (!isDeleted) {
        throw Exception('Failed to delete tag on the API.');
      }

      return (db.delete(db.tags)..where((tbl) => tbl.id.equals(tagId))).go();
    } catch (e) {
      print('Error deleting tag: $e');
      rethrow;
    }
  }

  // Batch insert or replace tags (used for syncing from API)
  Future<void> batchInsertOrReplaceTags(List<TagInDB> tags) async {
    await db.batch((batch) {
      for (var tag in tags) {
        batch.insert(
          db.tags,
          tag,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<int> insertTagFromAPI(TagInDB tag) {
    return db.into(db.tags).insert(tag);
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
