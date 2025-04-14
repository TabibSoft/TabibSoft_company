// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engineer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EngineerModel _$EngineerModelFromJson(Map<String, dynamic> json) =>
    EngineerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      telephone: json['telephone'] as String,
    );

Map<String, dynamic> _$EngineerModelToJson(EngineerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'telephone': instance.telephone,
    };
