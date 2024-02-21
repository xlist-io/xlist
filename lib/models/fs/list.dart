import 'package:json_annotation/json_annotation.dart';
import '../object.dart';
part 'list.g.dart';

@JsonSerializable()
class FsListModel {
  FsListModel();

  @JsonKey(name: 'content') List<ObjectModel>? content;
  @JsonKey(name: 'total') int? total;
  @JsonKey(name: 'readme') String? readme;
  @JsonKey(name: 'write') bool? write;
  @JsonKey(name: 'provider') String? provider;
  
  factory FsListModel.fromJson(Map<String,dynamic> json) => _$FsListModelFromJson(json);
  Map<String, dynamic> toJson() => _$FsListModelToJson(this);
}
