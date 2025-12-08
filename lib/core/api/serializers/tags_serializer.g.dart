// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_serializer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiTag _$ApiTagFromJson(Map<String, dynamic> json) => ApiTag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      displayOrder: (json['displayOrder'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$ApiTagToJson(ApiTag instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'displayOrder': instance.displayOrder,
      'description': instance.description,
    };
