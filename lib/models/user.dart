import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class UserModel {
  UserModel();

  @JsonKey(name: 'id') int? id;
  @JsonKey(name: 'username') String? username;
  @JsonKey(name: 'password') String? password;
  @JsonKey(name: 'base_path') String? basePath;
  @JsonKey(name: 'role') int? role;
  @JsonKey(name: 'permission') int? permission;
  @JsonKey(name: 'sso_id') String? sso_id;
  @JsonKey(name: 'disabled') bool? disabled;
  
  factory UserModel.fromJson(Map<String,dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
