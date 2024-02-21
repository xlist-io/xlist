// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel()
  ..id = json['id'] as int?
  ..username = json['username'] as String?
  ..password = json['password'] as String?
  ..basePath = json['base_path'] as String?
  ..role = json['role'] as int?
  ..permission = json['permission'] as int?
  ..sso_id = json['sso_id'] as String?
  ..disabled = json['disabled'] as bool?;

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'password': instance.password,
      'base_path': instance.basePath,
      'role': instance.role,
      'permission': instance.permission,
      'sso_id': instance.sso_id,
      'disabled': instance.disabled,
    };
