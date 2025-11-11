// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddNoteDto _$AddNoteDtoFromJson(Map<String, dynamic> json) => AddNoteDto(
      measurementId: json['measurementId'] as String,
      notes: json['notes'] as String?,
      expectedCallDate: json['exepectedCallDate'] == null
          ? null
          : DateTime.parse(json['exepectedCallDate'] as String),
      expectedCallTimeFrom: json['exepectedCallTimeFrom'] as String?,
      expectedCallTimeTo: json['exepectedCallTimeTo'] as String?,
      imageFiles: (json['imageFiles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AddNoteDtoToJson(AddNoteDto instance) =>
    <String, dynamic>{
      'measurementId': instance.measurementId,
      'notes': instance.notes,
      'exepectedCallDate': instance.expectedCallDate?.toIso8601String(),
      'exepectedCallTimeFrom': instance.expectedCallTimeFrom,
      'exepectedCallTimeTo': instance.expectedCallTimeTo,
      'imageFiles': instance.imageFiles,
    };
