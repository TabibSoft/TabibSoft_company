// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String?,
      date: NotificationModel._dateTimeFromJson(json['notfDate'] as String),
      isRead: json['isRecevie'] as bool,
      referenceId: json['referenceId'] as String?,
      engineerId: json['engineerId'] as String,
      engineer: json['engineer'],
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'notfDate': NotificationModel._dateTimeToJson(instance.date),
      'isRecevie': instance.isRead,
      'referenceId': instance.referenceId,
      'engineerId': instance.engineerId,
      'engineer': instance.engineer,
    };
