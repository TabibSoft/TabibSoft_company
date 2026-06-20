// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_hr_remote_work_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateHrRemoteWorkRequestModel _$CreateHrRemoteWorkRequestModelFromJson(
        Map<String, dynamic> json) =>
    CreateHrRemoteWorkRequestModel(
      startDate: DateTime.parse(json['startDate'] as String),
    );

Map<String, dynamic> _$CreateHrRemoteWorkRequestModelToJson(
        CreateHrRemoteWorkRequestModel instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
    };
