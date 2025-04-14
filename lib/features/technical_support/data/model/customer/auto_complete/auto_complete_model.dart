import 'package:json_annotation/json_annotation.dart';

part 'auto_complete_model.g.dart';

@JsonSerializable()
class AutoCompleteModel {
  final String id;
  final String name;
  final String telephone;

  AutoCompleteModel({
    required this.id,
    required this.name,
    required this.telephone,
  });

  factory AutoCompleteModel.fromJson(Map<String, dynamic> json) => _$AutoCompleteModelFromJson(json);
  Map<String, dynamic> toJson() => _$AutoCompleteModelToJson(this);
}
