// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_under_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUnderTransaction _$CreateUnderTransactionFromJson(
        Map<String, dynamic> json) =>
    CreateUnderTransaction(
      customerSupportId: json['customerSupportId'] as String,
      customerId: json['customerId'] as String,
      note: json['note'] as String?,
      problemstausId: (json['problemstausId'] as num).toInt(),
    );

Map<String, dynamic> _$CreateUnderTransactionToJson(
        CreateUnderTransaction instance) =>
    <String, dynamic>{
      'customerSupportId': instance.customerSupportId,
      'customerId': instance.customerId,
      'note': instance.note,
      'problemstausId': instance.problemstausId,
    };
