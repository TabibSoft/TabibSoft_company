import 'package:json_annotation/json_annotation.dart';

part 'create_hr_leave_request_model.g.dart';

@JsonSerializable()
class CreateHrLeaveRequestModel {
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;

  @JsonKey(includeIfNull: false)
  final String? reason;

  @JsonKey(includeIfNull: false)
  final String? startTime;

  @JsonKey(includeIfNull: false)
  final String? endTime;

  @JsonKey(includeIfNull: false)
  final int? hoursRequested;

  const CreateHrLeaveRequestModel({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.startTime,
    this.endTime,
    this.hoursRequested,
  });

  factory CreateHrLeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateHrLeaveRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateHrLeaveRequestModelToJson(this);
}
