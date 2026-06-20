// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_hr_leave_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateHrLeaveRequestModel _$CreateHrLeaveRequestModelFromJson(
        Map<String, dynamic> json) =>
    CreateHrLeaveRequestModel(
      leaveType: json['leaveType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      reason: json['reason'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      hoursRequested: (json['hoursRequested'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateHrLeaveRequestModelToJson(
        CreateHrLeaveRequestModel instance) =>
    <String, dynamic>{
      'leaveType': instance.leaveType,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      if (instance.reason case final value?) 'reason': value,
      if (instance.startTime case final value?) 'startTime': value,
      if (instance.endTime case final value?) 'endTime': value,
      if (instance.hoursRequested case final value?) 'hoursRequested': value,
    };
