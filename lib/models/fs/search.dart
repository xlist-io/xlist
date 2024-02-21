import 'package:json_annotation/json_annotation.dart';

part 'search.g.dart';

@JsonSerializable()
class FsSearchModel {
  FsSearchModel();

  @JsonKey(name: 'name') String? name;
  @JsonKey(name: 'parent') String? parent;
  @JsonKey(name: 'is_dir') bool? isDir;
  @JsonKey(name: 'type') int? type;
  @JsonKey(name: 'size') int? size;
  
  factory FsSearchModel.fromJson(Map<String,dynamic> json) => _$FsSearchModelFromJson(json);
  Map<String, dynamic> toJson() => _$FsSearchModelToJson(this);
}
