// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_customer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddCustomerResponse _$AddCustomerResponseFromJson(Map<String, dynamic> json) =>
    AddCustomerResponse(
      success: json['success'] as bool,
      customerId: (json['customerId'] as num).toInt(),
    );

Map<String, dynamic> _$AddCustomerResponseToJson(
        AddCustomerResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'customerId': instance.customerId,
    };
