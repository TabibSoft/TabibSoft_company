// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_visit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedVisitResponse _$PaginatedVisitResponseFromJson(
        Map<String, dynamic> json) =>
    PaginatedVisitResponse(
      totalRecords: (json['totalRecords'] as num).toInt(),
      pageNumber: (json['pageNumber'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => VisitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaginatedVisitResponseToJson(
        PaginatedVisitResponse instance) =>
    <String, dynamic>{
      'totalRecords': instance.totalRecords,
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'data': instance.data,
    };
