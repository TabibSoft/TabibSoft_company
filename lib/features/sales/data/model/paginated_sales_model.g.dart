// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_sales_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedSales _$PaginatedSalesFromJson(Map<String, dynamic> json) =>
    PaginatedSales(
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => SalesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaginatedSalesToJson(PaginatedSales instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
      'items': instance.items,
    };
