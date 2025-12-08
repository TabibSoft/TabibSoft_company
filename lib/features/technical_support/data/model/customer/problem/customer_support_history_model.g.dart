// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_support_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerSupportHistoryModel _$CustomerSupportHistoryModelFromJson(
        Map<String, dynamic> json) =>
    CustomerSupportHistoryModel(
      problemAddress: json['problemAddress'] as String?,
      details: json['details'] as String?,
      engName: json['engName'] as String?,
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
      createdUser: json['createdUser'] as String?,
    );

Map<String, dynamic> _$CustomerSupportHistoryModelToJson(
        CustomerSupportHistoryModel instance) =>
    <String, dynamic>{
      'problemAddress': instance.problemAddress,
      'details': instance.details,
      'engName': instance.engName,
      'dateTime': instance.dateTime?.toIso8601String(),
      'createdUser': instance.createdUser,
    };
