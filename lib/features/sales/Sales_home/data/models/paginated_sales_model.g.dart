// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_sales_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedSales _$PaginatedSalesFromJson(Map<String, dynamic> json) =>
    PaginatedSales(
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => SalesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaginatedSalesToJson(PaginatedSales instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'totalCount': instance.totalCount,
      'pageSize': instance.pageSize,
      'items': instance.items,
    };

SalesModel _$SalesModelFromJson(Map<String, dynamic> json) => SalesModel(
      id: json['id'] as String,
      customerName: json['customerName'] as String?,
      customerTelephone: json['customerTelephone'] as String?,
      productId: json['productId'] as String?,
      productName: json['proudctName'] as String?,
      statusName: json['statusName'] as String?,
      statusColor: json['statusColor'] as String?,
      address: json['address'] as String?,
      offerName: json['offerName'] as String?,
      note: json['note'] as String?,
      total: (json['total'] as num?)?.toInt(),
      date: json['date'] as String?,
      nextCallDate: json['nextCallDate'] as String?,
      fullName: json['fullName'] as String?,
      statusId: json['statusId'] as String?,
    );

Map<String, dynamic> _$SalesModelToJson(SalesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'customerTelephone': instance.customerTelephone,
      'productId': instance.productId,
      'proudctName': instance.productName,
      'statusName': instance.statusName,
      'statusColor': instance.statusColor,
      'address': instance.address,
      'offerName': instance.offerName,
      'note': instance.note,
      'total': instance.total,
      'date': instance.date,
      'nextCallDate': instance.nextCallDate,
      'fullName': instance.fullName,
      'statusId': instance.statusId,
    };
