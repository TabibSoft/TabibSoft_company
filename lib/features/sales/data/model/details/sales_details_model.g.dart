// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesDetailModel _$SalesDetailModelFromJson(Map<String, dynamic> json) =>
    SalesDetailModel(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      proudctName: json['proudctName'] as String,
      statusName: json['statusName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$SalesDetailModelToJson(SalesDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'proudctName': instance.proudctName,
      'statusName': instance.statusName,
      'createdAt': instance.createdAt.toIso8601String(),
      'note': instance.note,
    };
