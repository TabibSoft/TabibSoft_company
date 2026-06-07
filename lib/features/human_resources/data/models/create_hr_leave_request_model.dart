import 'package:json_annotation/json_annotation.dart';

part 'create_hr_leave_request_model.g.dart';

@JsonSerializable()
class CreateHrLeaveRequestModel {
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int hoursRequested;

  const CreateHrLeaveRequestModel({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.hoursRequested,
  });

  factory CreateHrLeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateHrLeaveRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateHrLeaveRequestModelToJson(this);
}
