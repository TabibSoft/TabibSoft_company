// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemModel _$ProblemModelFromJson(Map<String, dynamic> json) => ProblemModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      adderss: json['adderss'] as String?,
      problemtype: json['problemtype'] as String?,
      problemAddress: json['problemAddress'] as String?,
      phone: json['phone'] as String?,
      teacnicalSupportDate: json['teacnicalSupportDate'] as String?,
      problemDate: json['problemDate'] as String?,
      porblemColor: json['porblemColor'] as String?,
      products: json['products'] as List<dynamic>?,
      enginnerName: json['enginnerName'] as String?,
      details: json['details'] as String?,
      problemCategoryId: json['problemCategoryId'] as String?,
      image: json['image'] as String?,
      imageUrl: json['imageUrl'] as String?,
      problemStatusId: (json['problemStatusId'] as num?)?.toInt(),
      haveNotifications: json['haveNotifications'] as bool?,
      createdUser: json['createdUser'] as String?,
      status: json['status'] as String?,
      statusColor: json['statusColor'] as String?,
      statusIsArchieve: json['statusIsArchieve'] as bool?,
    );

Map<String, dynamic> _$ProblemModelToJson(ProblemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'adderss': instance.adderss,
      'problemtype': instance.problemtype,
      'problemAddress': instance.problemAddress,
      'phone': instance.phone,
      'teacnicalSupportDate': instance.teacnicalSupportDate,
      'problemDate': instance.problemDate,
      'porblemColor': instance.porblemColor,
      'products': instance.products,
      'enginnerName': instance.enginnerName,
      'details': instance.details,
      'problemCategoryId': instance.problemCategoryId,
      'image': instance.image,
      'imageUrl': instance.imageUrl,
      'problemStatusId': instance.problemStatusId,
      'haveNotifications': instance.haveNotifications,
      'createdUser': instance.createdUser,
      'status': instance.status,
      'statusColor': instance.statusColor,
      'statusIsArchieve': instance.statusIsArchieve,
    };
