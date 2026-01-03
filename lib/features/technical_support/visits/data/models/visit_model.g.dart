// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitModel _$VisitModelFromJson(Map<String, dynamic> json) => VisitModel(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String? ?? '',
      note: json['note'] as String? ?? '',
      visitType: json['visitType'] as String? ?? '',
      visitDate: DateTime.parse(json['visitDate'] as String),
      visitId: json['visitId'] as String,
      engineerName: json['engineerName'] as String? ?? 'غير محدد',
      proudctName: json['proudctName'] as String? ?? '--',
      adress: json['adress'] as String? ?? 'لا يوجد عنوان تفصيلي',
      location: json['location'] as String? ?? 'غير محدد',
      status: json['status'] as String? ?? 'غير محدد',
      statusId: json['statusId'] as String? ?? '',
      statusColor: json['statusColor'] as String? ?? '#808080',
      isInstallDone: json['isInstall'] as bool,
      totalRate: (json['totalRate'] as num).toDouble(),
      isArchive: json['isArchive'] as bool?,
      visitInstallDetails: json['visitInstallDetails'] as List<dynamic>? ?? [],
    );

Map<String, dynamic> _$VisitModelToJson(VisitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'note': instance.note,
      'visitType': instance.visitType,
      'visitDate': instance.visitDate.toIso8601String(),
      'visitId': instance.visitId,
      'engineerName': instance.engineerName,
      'proudctName': instance.proudctName,
      'adress': instance.adress,
      'location': instance.location,
      'status': instance.status,
      'statusId': instance.statusId,
      'statusColor': instance.statusColor,
      'isInstall': instance.isInstallDone,
      'totalRate': instance.totalRate,
      'isArchive': instance.isArchive,
      'visitInstallDetails': instance.visitInstallDetails,
    };
