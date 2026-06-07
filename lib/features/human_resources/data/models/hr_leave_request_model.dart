import 'package:json_annotation/json_annotation.dart';

part 'hr_leave_request_model.g.dart';

@JsonSerializable()
class HrLeaveRequestModel {
  final String? id;
  final String? employeeProfileId;
  final String? employeeName;
  final String? leaveType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? totalDays;
  final int? hoursRequested;
  final String? status;
  final String? rejectionReason;
  final DateTime? createdDate;

  const HrLeaveRequestModel({
    this.id,
    this.employeeProfileId,
    this.employeeName,
    this.leaveType,
    this.startDate,
    this.endDate,
    this.totalDays,
    this.hoursRequested,
    this.status,
    this.rejectionReason,
    this.createdDate,
  });

  factory HrLeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      _$HrLeaveRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$HrLeaveRequestModelToJson(this);
}
