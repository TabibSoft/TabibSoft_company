// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_call_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayCallModel _$TodayCallModelFromJson(Map<String, dynamic> json) =>
    TodayCallModel(
      id: json['id'] as String?,
      measurementId: json['measurementId'] as String?,
      type: json['type'] as String?,
      notes: json['notes'] as String?,
      exepectedComment: json['exepectedComment'] as String?,
      exepectedCallDate: json['exepectedCallDate'] == null
          ? null
          : DateTime.parse(json['exepectedCallDate'] as String),
      exepectedCallTimeFrom: json['exepectedCallTimeFrom'] as String?,
      exepectedCallTimeTo: json['exepectedCallTimeTo'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      creatDate: json['creatDate'] == null
          ? null
          : DateTime.parse(json['creatDate'] as String),
      civilnumber: json['civilnumber'] as String?,
      customer: json['customer'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      requireImages: (json['requireImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      count: (json['count'] as num?)?.toInt(),
      communicationId: json['communicationId'] as String?,
    );

Map<String, dynamic> _$TodayCallModelToJson(TodayCallModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'measurementId': instance.measurementId,
      'type': instance.type,
      'notes': instance.notes,
      'exepectedComment': instance.exepectedComment,
      'exepectedCallDate': instance.exepectedCallDate?.toIso8601String(),
      'exepectedCallTimeFrom': instance.exepectedCallTimeFrom,
      'exepectedCallTimeTo': instance.exepectedCallTimeTo,
      'date': instance.date?.toIso8601String(),
      'creatDate': instance.creatDate?.toIso8601String(),
      'civilnumber': instance.civilnumber,
      'customer': instance.customer,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'requireImages': instance.requireImages,
      'imageUrl': instance.imageUrl,
      'count': instance.count,
      'communicationId': instance.communicationId,
    };
