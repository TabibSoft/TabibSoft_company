import 'package:json_annotation/json_annotation.dart';

part 'section_model.g.dart';

@JsonSerializable()
class SectionModel {
  final String id;
  final String name;
  @JsonKey(defaultValue: false)
  final bool isTest;

  SectionModel({
    required this.id,
    required this.name,
    required this.isTest,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) =>
      _$SectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SectionModelToJson(this);
}
