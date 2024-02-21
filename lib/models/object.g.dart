// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObjectModel _$ObjectModelFromJson(Map<String, dynamic> json) => ObjectModel()
  ..name = json['name'] as String?
  ..type = json['type'] as int?
  ..thumb = json['thumb'] as String?
  ..isDir = json['is_dir'] as bool?
  ..modified = json['modified'] == null
      ? null
      : DateTime.parse(json['modified'] as String)
  ..size = json['size'] as int?
  ..sign = json['sign'] as String?
  ..rawUrl = json['raw_url'] as String?
  ..readme = json['readme'] as String?
  ..provider = json['provider'] as String?
  ..related = (json['related'] as List<dynamic>?)
      ?.map((e) => ObjectModel.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$ObjectModelToJson(ObjectModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'thumb': instance.thumb,
      'is_dir': instance.isDir,
      'modified': instance.modified?.toIso8601String(),
      'size': instance.size,
      'sign': instance.sign,
      'raw_url': instance.rawUrl,
      'readme': instance.readme,
      'provider': instance.provider,
      'related': instance.related,
    };
