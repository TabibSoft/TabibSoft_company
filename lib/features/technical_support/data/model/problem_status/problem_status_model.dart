// lib/features/technical_support/data/model/problem_status_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'problem_status_model.g.dart';

@JsonSerializable()
class ProblemStatusModel {
  final int id;
  final String name;

  ProblemStatusModel({required this.id, required this.name});

  factory ProblemStatusModel.fromJson(Map<String, dynamic> json) => _$ProblemStatusModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProblemStatusModelToJson(this);
}