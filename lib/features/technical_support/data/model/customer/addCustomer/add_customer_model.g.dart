// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddCustomerModel _$AddCustomerModelFromJson(Map<String, dynamic> json) =>
    AddCustomerModel(
      name: json['name'] as String,
      telephone: json['telephone'] as String,
      engineerId: json['engineerId'] as String,
      productId: json['productId'] as String,
      location: json['location'] as String?,
      createdUser: json['createdUser'] as String?,
      lastEditUser: json['lastEditUser'] as String?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      lastEditDate: json['lastEditDate'] == null
          ? null
          : DateTime.parse(json['lastEditDate'] as String),
    );

Map<String, dynamic> _$AddCustomerModelToJson(AddCustomerModel instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'telephone': instance.telephone,
    'engineerId': instance.engineerId,
    'productId': instance.productId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('location', instance.location);
  writeNotNull('createdUser', instance.createdUser);
  writeNotNull('lastEditUser', instance.lastEditUser);
  writeNotNull('createdDate', instance.createdDate?.toIso8601String());
  writeNotNull('lastEditDate', instance.lastEditDate?.toIso8601String());
  return val;
}
