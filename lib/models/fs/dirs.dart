import 'package:json_annotation/json_annotation.dart';

part 'dirs.g.dart';

@JsonSerializable()
class FsDirsModel {
  FsDirsModel();

  @JsonKey(name: 'name') String? name;
  @JsonKey(name: 'modified') DateTime? modified;
  
  factory FsDirsModel.fromJson(Map<String,dynamic> json) => _$FsDirsModelFromJson(json);
  Map<String, dynamic> toJson() => _$FsDirsModelToJson(this);
}
