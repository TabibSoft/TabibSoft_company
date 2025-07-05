// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customization_task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomizationTaskModel _$CustomizationTaskModelFromJson(
        Map<String, dynamic> json) =>
    CustomizationTaskModel(
      id: json['id'] as String,
      name: json['name'] as String,
      customization: (json['customization'] as List<dynamic>)
          .map((e) => Customization.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CustomizationTaskModelToJson(
        CustomizationTaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'customization': instance.customization,
    };

Customization _$CustomizationFromJson(Map<String, dynamic> json) =>
    Customization(
      id: json['id'] as String,
      engName: json['engName'] as String? ?? '',
      projectName: json['projectName'] as String,
      reports: (json['reports'] as List<dynamic>)
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList(),
      situationStatus: SituationStatus.fromJson(
          json['sitiouationStatus'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CustomizationToJson(Customization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'engName': instance.engName,
      'projectName': instance.projectName,
      'reports': instance.reports,
      'sitiouationStatus': instance.situationStatus,
    };

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['note'] as String? ?? '',
      finished: json['finshed'] as bool,
      time: (json['time'] as num).toInt(),
    );

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'note': instance.notes,
      'finshed': instance.finished,
      'time': instance.time,
    };

SituationStatus _$SituationStatusFromJson(Map<String, dynamic> json) =>
    SituationStatus(
      color: json['color'] as String,
      name: json['name'] as String,
      id: json['id'] as String,
      createdUser: json['createdUser'] as String?,
      lastEditUser: json['lastEditUser'] as String?,
      createdDate: json['createdDate'] as String,
      lastEditDate: json['lastEditDate'] as String,
    );

Map<String, dynamic> _$SituationStatusToJson(SituationStatus instance) =>
    <String, dynamic>{
      'color': instance.color,
      'name': instance.name,
      'id': instance.id,
      'createdUser': instance.createdUser,
      'lastEditUser': instance.lastEditUser,
      'createdDate': instance.createdDate,
      'lastEditDate': instance.lastEditDate,
    };
