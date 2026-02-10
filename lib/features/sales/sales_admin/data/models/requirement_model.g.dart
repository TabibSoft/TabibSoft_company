// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requirement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequirementReport _$RequirementReportFromJson(Map<String, dynamic> json) =>
    RequirementReport(
      id: json['requirementId'] as String,
      measurementId: json['measurementId'] as String?,
      customerName: json['customerName'] as String,
      salesPersonName: json['salesName'] as String,
      programName: json['programName'] as String,
      note: json['note'] as String?,
      creationDate: json['createdDate'] as String,
      nextCallDate: json['nextCallDate'] as String,
      imagesList: json['images'] as List<dynamic>?,
      adminNote: json['adminNote'] as String?,
      adminNoteUser: json['adminNoteUser'] as String?,
      adminNoteDate: json['adminNoteDate'] as String?,
      statusName: json['statusName'] as String,
      statusColor: json['statusColor'] as String?,
    );

Map<String, dynamic> _$RequirementReportToJson(RequirementReport instance) =>
    <String, dynamic>{
      'requirementId': instance.id,
      'measurementId': instance.measurementId,
      'customerName': instance.customerName,
      'salesName': instance.salesPersonName,
      'programName': instance.programName,
      'note': instance.note,
      'createdDate': instance.creationDate,
      'nextCallDate': instance.nextCallDate,
      'images': instance.imagesList,
      'adminNote': instance.adminNote,
      'adminNoteUser': instance.adminNoteUser,
      'adminNoteDate': instance.adminNoteDate,
      'statusName': instance.statusName,
      'statusColor': instance.statusColor,
    };

PaginatedRequirements _$PaginatedRequirementsFromJson(
        Map<String, dynamic> json) =>
    PaginatedRequirements(
      data: (json['data'] as List<dynamic>)
          .map((e) => RequirementReport.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusCounts: (json['statusCounts'] as List<dynamic>?)
          ?.map((e) => StatusCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      totalRecords: (json['totalRecords'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaginatedRequirementsToJson(
        PaginatedRequirements instance) =>
    <String, dynamic>{
      'data': instance.data,
      'statusCounts': instance.statusCounts,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'totalRecords': instance.totalRecords,
    };

SalesPerson _$SalesPersonFromJson(Map<String, dynamic> json) => SalesPerson(
      id: json['id'] as String,
      name: json['name'] as String,
      telephone: json['telephone'] as String?,
    );

Map<String, dynamic> _$SalesPersonToJson(SalesPerson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'telephone': instance.telephone,
    };

StatusCount _$StatusCountFromJson(Map<String, dynamic> json) => StatusCount(
      statusName: json['statusName'] as String,
      statusColor: json['statusColor'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$StatusCountToJson(StatusCount instance) =>
    <String, dynamic>{
      'statusName': instance.statusName,
      'statusColor': instance.statusColor,
      'count': instance.count,
    };
