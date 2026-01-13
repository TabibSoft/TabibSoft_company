import 'package:json_annotation/json_annotation.dart';

part 'status_model.g.dart';

@JsonSerializable()
class StatusModel {
  final String id;
  final String name;
  final String color;
  final bool isArchieve;
  final String? createdUser;
  final String? lastEditUser;
  final String? createdDate;
  final String? lastEditDate;
  StatusModel({
    required this.id,
    required this.name,
    required this.color,
    required this.isArchieve,
    this.createdUser,
    this.lastEditUser,
    this.createdDate,
    this.lastEditDate,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) =>
      _$StatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatusModelToJson(this);
}