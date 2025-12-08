// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technical_support_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TechnicalSupportDetailsModel _$TechnicalSupportDetailsModelFromJson(
        Map<String, dynamic> json) =>
    TechnicalSupportDetailsModel(
      customerSupportId: json['customerSupportId'] as String?,
      id: json['id'] as String?,
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
      problemKindName: json['problemKindName'] as String?,
      problemStatusName: json['problemStatusName'] as String?,
      note: json['note'] as String?,
      solvidDate: json['solvidDate'] == null
          ? null
          : DateTime.parse(json['solvidDate'] as String),
      solvid: json['solvid'] as bool?,
      details: json['details'] as String?,
      location: json['location'] as String?,
      name: json['name'] as String?,
      problemCategoryName: json['problemCategoryName'] as String?,
      problemStatusId: json['problemStatusId'] as int?,
      telephone: json['telephone'] as String?,
      engineer: json['engineer'] as String?,
      isTransaction: json['isTransaction'] as bool?,
      problemAddress: json['problemAddress'] as String?,
      transactionNote: json['transactionNote'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      teacnicalSupportDate: json['teacnicalSupportDate'] == null
          ? null
          : DateTime.parse(json['teacnicalSupportDate'] as String),
      enginnerId: json['enginnerId'] as String?,
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      contactPhone: json['contactPhone'] as String?,
      transactionId: json['transactionId'] as String?,
      underTransactionDate: json['underTransactionDate'] == null
          ? null
          : DateTime.parse(json['underTransactionDate'] as String),
      underTransactions: json['underTransactions'] as List<dynamic>?,
      customerSupport: (json['customerSupport'] as List<dynamic>?)
          ?.map((e) =>
              CustomerSupportHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TechnicalSupportDetailsModelToJson(
        TechnicalSupportDetailsModel instance) =>
    <String, dynamic>{
      'customerSupportId': instance.customerSupportId,
      'id': instance.id,
      'dateTime': instance.dateTime?.toIso8601String(),
      'problemKindName': instance.problemKindName,
      'problemStatusName': instance.problemStatusName,
      'note': instance.note,
      'solvidDate': instance.solvidDate?.toIso8601String(),
      'solvid': instance.solvid,
      'details': instance.details,
      'location': instance.location,
      'name': instance.name,
      'problemCategoryName': instance.problemCategoryName,
      'problemStatusId': instance.problemStatusId,
      'telephone': instance.telephone,
      'engineer': instance.engineer,
      'isTransaction': instance.isTransaction,
      'problemAddress': instance.problemAddress,
      'transactionNote': instance.transactionNote,
      'images': instance.images,
      'teacnicalSupportDate': instance.teacnicalSupportDate?.toIso8601String(),
      'enginnerId': instance.enginnerId,
      'products': instance.products,
      'contactPhone': instance.contactPhone,
      'transactionId': instance.transactionId,
      'underTransactionDate': instance.underTransactionDate?.toIso8601String(),
      'underTransactions': instance.underTransactions,
      'customerSupport':
          instance.customerSupport?.map((e) => e.toJson()).toList(),
    };
