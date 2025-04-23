import 'package:json_annotation/json_annotation.dart';

part 'problem_category_model.g.dart';

@JsonSerializable()
class ProblemCategoryModel {
  final String id;
  final String name;

  ProblemCategoryModel({required this.id, required this.name});

  factory ProblemCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$ProblemCategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProblemCategoryModelToJson(this);
}
