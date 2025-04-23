// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_requirement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddMeasurementRequirement _$AddMeasurementRequirementFromJson(
        Map<String, dynamic> json) =>
    AddMeasurementRequirement(
      id: json['id'] as String,
      createdUser: json['createdUser'] as String?,
      lastEditUser: json['lastEditUser'] as String?,
      createdDate: json['createdDate'] as String,
      lastEditDate: json['lastEditDate'] as String,
      measurementId: json['measurementId'] as String,
      notes: json['notes'] as String?,
      exepectedCallDate: json['exepectedCallDate'] as String,
      exepectedCallTimeFrom: json['exepectedCallTimeFrom'] as String,
      exepectedCallTimeTo: json['exepectedCallTimeTo'] as String,
      date: json['date'] as String?,
      exepectedComment: json['exepectedComment'] as String?,
      note: json['note'] as String?,
      imageFiles: (json['imageFiles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      communicationId: json['communicationId'] as String?,
      model: json['model'] as String?,
    );

Map<String, dynamic> _$AddMeasurementRequirementToJson(
        AddMeasurementRequirement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdUser': instance.createdUser,
      'lastEditUser': instance.lastEditUser,
      'createdDate': instance.createdDate,
      'lastEditDate': instance.lastEditDate,
      'measurementId': instance.measurementId,
      'notes': instance.notes,
      'exepectedCallDate': instance.exepectedCallDate,
      'exepectedCallTimeFrom': instance.exepectedCallTimeFrom,
      'exepectedCallTimeTo': instance.exepectedCallTimeTo,
      'date': instance.date,
      'exepectedComment': instance.exepectedComment,
      'note': instance.note,
      'imageFiles': instance.imageFiles,
      'communicationId': instance.communicationId,
      'model': instance.model,
    };

TimeSpan _$TimeSpanFromJson(Map<String, dynamic> json) => TimeSpan(
      ticks: (json['ticks'] as num).toInt(),
    );

Map<String, dynamic> _$TimeSpanToJson(TimeSpan instance) => <String, dynamic>{
      'ticks': instance.ticks,
    };
