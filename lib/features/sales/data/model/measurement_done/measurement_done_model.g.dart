// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_done_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeasurementDoneDto _$MeasurementDoneDtoFromJson(Map<String, dynamic> json) =>
    MeasurementDoneDto(
      id: json['id'] as String,
      location: json['location'] as String?,
      offerId: json['offerId'] as String,
      adress: json['adress'] as String?,
      note: json['note'] as String?,
      total: (json['total'] as num).toDouble(),
      installingDate: DateTime.parse(json['installingDate'] as String),
      installingNote: json['installingNote'] as String?,
      teacnicalSupportDate:
          DateTime.parse(json['teacnicalSupportDate'] as String),
      customerReview: json['customerReview'] as String?,
      realEngineerId: json['realEngineerId'] as String,
      customerId: json['customerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      hasCustomization: json['hasCustomization'] as bool,
      image: json['image'] as String?,
      measurementDone: json['measurementDone'] as String?,
    );

Map<String, dynamic> _$MeasurementDoneDtoToJson(MeasurementDoneDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'location': instance.location,
      'offerId': instance.offerId,
      'adress': instance.adress,
      'note': instance.note,
      'total': instance.total,
      'installingDate': instance.installingDate.toIso8601String(),
      'installingNote': instance.installingNote,
      'teacnicalSupportDate': instance.teacnicalSupportDate.toIso8601String(),
      'customerReview': instance.customerReview,
      'realEngineerId': instance.realEngineerId,
      'customerId': instance.customerId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'hasCustomization': instance.hasCustomization,
      'image': instance.image,
      'measurementDone': instance.measurementDone,
    };
