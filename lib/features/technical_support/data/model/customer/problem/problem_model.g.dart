// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemModel _$ProblemModelFromJson(Map<String, dynamic> json) => ProblemModel(
      id: json['id'] as String?,
      customerId: json['customerId'] as String?,
      customerSupportId: json['customerSupportId'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      adderss: json['adderss'] as String?,
      problemtype: json['problemtype'] as String?,
      problemAddress: json['problemAddress'] as String?,
      problemDetails: json['problemDetails'] as String?,
      phone: json['phone'] as String?,
      problemDate: json['problemDate'] as String?,
      createDate: json['createDate'] as String?,
      porblemColor: json['porblemColor'] as String?,
      enginnerName: json['enginnerName'] as String?,
      details: json['details'] as String?,
      image: json['image'] as String?,
      imageUrl: json['imageUrl'] as String?,
      problemStatusId: (json['problemStatusId'] as num?)?.toInt(),
      statusColor: json['statusColor'] as String?,
      isUrgent: json['isUrgent'] as bool?,
      isArchive: json['isArchive'] as bool?,
      statusIsArchieveRaw: json['statusIsArchieve'] as bool?,
      products: json['products'] as List<dynamic>?,
      images: json['images'] as List<dynamic>?,
      customerSupport: json['customerSupport'] as List<dynamic>?,
      underTransactions: json['underTransactions'] as List<dynamic>?,
      name: json['name'] as String?,
      location: json['location'] as String?,
      telephone: json['telephone'] as String?,
    );

Map<String, dynamic> _$ProblemModelToJson(ProblemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerSupportId': instance.customerSupportId,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'adderss': instance.adderss,
      'problemtype': instance.problemtype,
      'problemAddress': instance.problemAddress,
      'problemDetails': instance.problemDetails,
      'phone': instance.phone,
      'problemDate': instance.problemDate,
      'createDate': instance.createDate,
      'porblemColor': instance.porblemColor,
      'enginnerName': instance.enginnerName,
      'details': instance.details,
      'image': instance.image,
      'imageUrl': instance.imageUrl,
      'problemStatusId': instance.problemStatusId,
      'statusColor': instance.statusColor,
      'isUrgent': instance.isUrgent,
      'isArchive': instance.isArchive,
      'statusIsArchieve': instance.statusIsArchieveRaw,
      'products': instance.products,
      'images': instance.images,
      'customerSupport': instance.customerSupport,
      'underTransactions': instance.underTransactions,
      'name': instance.name,
      'location': instance.location,
      'telephone': instance.telephone,
    };
