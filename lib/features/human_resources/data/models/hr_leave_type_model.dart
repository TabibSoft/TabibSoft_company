import 'package:json_annotation/json_annotation.dart';

part 'hr_leave_type_model.g.dart';

@JsonSerializable()
class HrLeaveTypeModel {
  final int? id;
  final String? name;
  final String? displayName;

  const HrLeaveTypeModel({
    this.id,
    this.name,
    this.displayName,
  });

  factory HrLeaveTypeModel.fromJson(Map<String, dynamic> json) =>
      _$HrLeaveTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$HrLeaveTypeModelToJson(this);
}
