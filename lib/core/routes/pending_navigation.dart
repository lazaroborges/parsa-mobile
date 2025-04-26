import 'package:flutter/widgets.dart';
import 'package:parsa/core/api/fetch_user_tags_service.dart';
import 'package:parsa/core/database/services/tags/tags_service.dart';
import 'package:parsa/core/models/tags/tag.dart';
import 'package:parsa/core/database/app_db.dart';

class PendingNavigation {
  final String route;
  final String? id;
  final Future<dynamic>? dataFuture;

  PendingNavigation({
    required this.route,
    this.id,
    this.dataFuture,
  });
}

PendingNavigation? pendingNavigation;

Future<TagInDB?> fetchAndFindTagById(BuildContext context, String tagId) async {
  await fetchUserTags(context); // Fetch and sync all tags
  return await TagService.instance.getTagById(tagId).first;
}
