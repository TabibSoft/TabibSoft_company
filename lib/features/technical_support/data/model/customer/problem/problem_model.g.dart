// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemModel _$ProblemModelFromJson(Map<String, dynamic> json) => ProblemModel(
      id: json['id'] as String?,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      adderss: json['adderss'] as String?,
      title: json['problemtype'] as String?,
      problemAddress: json['problemAddress'] as String?,
      problemDetails: json['problemDetails'] as String?,
      phone: json['phone'] as String?,
      problemDate: json['problemDate'] as String?,
      porblemColor: json['porblemColor'] as String?,
      enginnerName: json['enginnerName'] as String?,
      details: json['details'] as String?,
      image: json['image'] as String?,
      imageUrl: json['imageUrl'] as String?,
      problemStatusId: (json['problemStatusId'] as num?)?.toInt(),
      statusColor: json['statusColor'] as String?,
      isUrgent: json['isUrgent'] as bool?,
    );

Map<String, dynamic> _$ProblemModelToJson(ProblemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'adderss': instance.adderss,
      'problemtype': instance.title,
      'problemAddress': instance.problemAddress,
      'problemDetails': instance.problemDetails,
      'phone': instance.phone,
      'problemDate': instance.problemDate,
      'porblemColor': instance.porblemColor,
      'enginnerName': instance.enginnerName,
      'details': instance.details,
      'image': instance.image,
      'imageUrl': instance.imageUrl,
      'problemStatusId': instance.problemStatusId,
      'statusColor': instance.statusColor,
      'isUrgent': instance.isUrgent,
    };
