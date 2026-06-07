// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_leave_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HrLeaveTypeModel _$HrLeaveTypeModelFromJson(Map<String, dynamic> json) =>
    HrLeaveTypeModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      displayName: json['displayName'] as String?,
    );

Map<String, dynamic> _$HrLeaveTypeModelToJson(HrLeaveTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'displayName': instance.displayName,
    };
