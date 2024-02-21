// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dirs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FsDirsModel _$FsDirsModelFromJson(Map<String, dynamic> json) => FsDirsModel()
  ..name = json['name'] as String?
  ..modified = json['modified'] == null
      ? null
      : DateTime.parse(json['modified'] as String);

Map<String, dynamic> _$FsDirsModelToJson(FsDirsModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'modified': instance.modified?.toIso8601String(),
    };
