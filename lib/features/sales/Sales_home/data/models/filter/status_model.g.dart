// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusModel _$StatusModelFromJson(Map<String, dynamic> json) => StatusModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      isArchieve: json['isArchieve'] as bool,
      createdUser: json['createdUser'] as String?,
      lastEditUser: json['lastEditUser'] as String?,
      createdDate: json['createdDate'] as String?,
      lastEditDate: json['lastEditDate'] as String?,
    );

Map<String, dynamic> _$StatusModelToJson(StatusModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'isArchieve': instance.isArchieve,
      'createdUser': instance.createdUser,
      'lastEditUser': instance.lastEditUser,
      'createdDate': instance.createdDate,
      'lastEditDate': instance.lastEditDate,
    };
