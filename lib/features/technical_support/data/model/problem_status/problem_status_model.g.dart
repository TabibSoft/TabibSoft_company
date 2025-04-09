// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemStatusModel _$ProblemStatusModelFromJson(Map<String, dynamic> json) =>
    ProblemStatusModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$ProblemStatusModelToJson(ProblemStatusModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
