// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskUpdateModel _$TaskUpdateModelFromJson(Map<String, dynamic> json) =>
    TaskUpdateModel(
      id: json['id'] as String,
      image: json['image'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      deadLine: DateTime.parse(json['deadLine'] as String),
      engRate: (json['engRate'] as num?)?.toDouble(),
      testing: json['testing'] as bool,
      applaied: json['applaied'] as bool,
      enginnerTesterId: json['enginnerTesterId'] as String?,
      engineerIds: (json['engineerIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      customerSupportId: json['customerSupportId'] as String?,
      customerId: json['customerId'] as String,
      detailes: json['detailes'] as String,
      reports: (json['customizationReports'] as List<dynamic>)
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList(),
      sitiouationStatusesId: json['sitiouationStatusesId'] as String,
      sitiouationId: json['sitiouationId'] as String,
      file: json['file'] as String?,
    );

Map<String, dynamic> _$TaskUpdateModelToJson(TaskUpdateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'startDate': instance.startDate.toIso8601String(),
      'deadLine': instance.deadLine.toIso8601String(),
      'engRate': instance.engRate,
      'testing': instance.testing,
      'applaied': instance.applaied,
      'enginnerTesterId': instance.enginnerTesterId,
      'engineerIds': instance.engineerIds,
      'customerSupportId': instance.customerSupportId,
      'customerId': instance.customerId,
      'detailes': instance.detailes,
      'customizationReports': instance.reports,
      'sitiouationStatusesId': instance.sitiouationStatusesId,
      'sitiouationId': instance.sitiouationId,
      'file': instance.file,
    };

ReportDoneModel _$ReportDoneModelFromJson(Map<String, dynamic> json) =>
    ReportDoneModel(
      id: json['id'] as String,
    );

Map<String, dynamic> _$ReportDoneModelToJson(ReportDoneModel instance) =>
    <String, dynamic>{
      'id': instance.id,
    };
