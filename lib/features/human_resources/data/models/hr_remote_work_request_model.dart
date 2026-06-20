import 'package:json_annotation/json_annotation.dart';

part 'hr_remote_work_request_model.g.dart';

@JsonSerializable()
class HrRemoteWorkRequestModel {
  final String? id;
  final String? employeeProfileId;
  final String? employeeName;
  final DateTime? date;
  final String? status;
  final String? rejectionReason;
  final String? rejectedBy;
  final DateTime? createdDate;

  const HrRemoteWorkRequestModel({
    this.id,
    this.employeeProfileId,
    this.employeeName,
    this.date,
    this.status,
    this.rejectionReason,
    this.rejectedBy,
    this.createdDate,
  });

  factory HrRemoteWorkRequestModel.fromJson(Map<String, dynamic> json) =>
      _$HrRemoteWorkRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$HrRemoteWorkRequestModelToJson(this);
}
