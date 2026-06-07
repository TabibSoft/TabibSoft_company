// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_leave_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HrLeaveRequestModel _$HrLeaveRequestModelFromJson(Map<String, dynamic> json) =>
    HrLeaveRequestModel(
      id: json['id'] as String?,
      employeeProfileId: json['employeeProfileId'] as String?,
      employeeName: json['employeeName'] as String?,
      leaveType: json['leaveType'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      totalDays: (json['totalDays'] as num?)?.toInt(),
      hoursRequested: (json['hoursRequested'] as num?)?.toInt(),
      status: json['status'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
    );

Map<String, dynamic> _$HrLeaveRequestModelToJson(
        HrLeaveRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeProfileId': instance.employeeProfileId,
      'employeeName': instance.employeeName,
      'leaveType': instance.leaveType,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'totalDays': instance.totalDays,
      'hoursRequested': instance.hoursRequested,
      'status': instance.status,
      'rejectionReason': instance.rejectionReason,
      'createdDate': instance.createdDate?.toIso8601String(),
    };
