// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesModel _$SalesModelFromJson(Map<String, dynamic> json) => SalesModel(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerTelephone: json['customerTelephone'] as String,
      fullName: json['fullName'] as String,
      statusName: json['statusName'] as String,
      proudctName: json['proudctName'] as String,
      productId: json['productId'] as String,
      note: json['note'] as String?,
      adress: json['adress'] as String?,
      offerName: json['offerName'] as String?,
      total: (json['total'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SalesModelToJson(SalesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'customerTelephone': instance.customerTelephone,
      'fullName': instance.fullName,
      'statusName': instance.statusName,
      'proudctName': instance.proudctName,
      'productId': instance.productId,
      'note': instance.note,
      'adress': instance.adress,
      'offerName': instance.offerName,
      'total': instance.total,
    };
