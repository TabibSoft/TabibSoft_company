import 'package:json_annotation/json_annotation.dart';

part 'engineer_model.g.dart';

@JsonSerializable()
class EngineerModel {
  final String? id;
  final String? name;
  final String? address;
  final String? telephone;

  EngineerModel({
    this.id,
    this.name,
    this.address,
    this.telephone,
  });

  factory EngineerModel.fromJson(Map<String, dynamic> json) =>
      _$EngineerModelFromJson(json);
  Map<String, dynamic> toJson() => _$EngineerModelToJson(this);
}
