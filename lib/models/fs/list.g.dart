// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FsListModel _$FsListModelFromJson(Map<String, dynamic> json) => FsListModel()
  ..content = (json['content'] as List<dynamic>?)
      ?.map((e) => ObjectModel.fromJson(e as Map<String, dynamic>))
      .toList()
  ..total = json['total'] as int?
  ..readme = json['readme'] as String?
  ..write = json['write'] as bool?
  ..provider = json['provider'] as String?;

Map<String, dynamic> _$FsListModelToJson(FsListModel instance) =>
    <String, dynamic>{
      'content': instance.content,
      'total': instance.total,
      'readme': instance.readme,
      'write': instance.write,
      'provider': instance.provider,
    };
