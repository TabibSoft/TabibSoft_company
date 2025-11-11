// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesDetailModel _$SalesDetailModelFromJson(Map<String, dynamic> json) =>
    SalesDetailModel(
      id: json['id'] as String,
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      endTotal: (json['endTotal'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      offerId: json['offerId'] as String?,
      offerName: json['offerName'] as String?,
      note: json['note'] as String?,
      engineerId: json['engineerId'] as String,
      engineerName: json['engineerName'] as String,
      measurementRequirement: (json['measurementRequirement'] as List<dynamic>)
          .map(
              (e) => MeasurementRequirement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SalesDetailModelToJson(SalesDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'discount': instance.discount,
      'total': instance.total,
      'endTotal': instance.endTotal,
      'date': instance.date.toIso8601String(),
      'offerId': instance.offerId,
      'offerName': instance.offerName,
      'note': instance.note,
      'engineerId': instance.engineerId,
      'engineerName': instance.engineerName,
      'measurementRequirement': instance.measurementRequirement,
    };

MeasurementRequirement _$MeasurementRequirementFromJson(
        Map<String, dynamic> json) =>
    MeasurementRequirement(
      id: json['id'] as String,
      measurementId: json['measurementId'] as String,
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
      requireImages: (json['requireImages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      count: (json['count'] as num).toInt(),
      communicationId: json['communicationId'] as String?,
    );

Map<String, dynamic> _$MeasurementRequirementToJson(
        MeasurementRequirement instance) =>
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
