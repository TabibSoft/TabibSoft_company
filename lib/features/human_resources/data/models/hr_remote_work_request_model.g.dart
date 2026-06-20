// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_remote_work_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HrRemoteWorkRequestModel _$HrRemoteWorkRequestModelFromJson(
        Map<String, dynamic> json) =>
    HrRemoteWorkRequestModel(
      id: json['id'] as String?,
      employeeProfileId: json['employeeProfileId'] as String?,
      employeeName: json['employeeName'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      status: json['status'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      rejectedBy: json['rejectedBy'] as String?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
    );

Map<String, dynamic> _$HrRemoteWorkRequestModelToJson(
        HrRemoteWorkRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeProfileId': instance.employeeProfileId,
      'employeeName': instance.employeeName,
      'date': instance.date?.toIso8601String(),
      'status': instance.status,
      'rejectionReason': instance.rejectionReason,
      'rejectedBy': instance.rejectedBy,
      'createdDate': instance.createdDate?.toIso8601String(),
    };
