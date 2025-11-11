import 'package:json_annotation/json_annotation.dart';

part 'paginated_sales_model.g.dart';

@JsonSerializable()
class PaginatedSales {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final List<SalesModel> items;

  PaginatedSales({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    required this.items,
  });

  factory PaginatedSales.fromJson(Map<String, dynamic> json) =>
      _$PaginatedSalesFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedSalesToJson(this);
}

@JsonSerializable()
class SalesModel {
  final String id;
  final String? customerName;
  final String? customerTelephone;
  @JsonKey(name: 'productId')
  final String? productId;
  @JsonKey(name: 'proudctName')
  final String? productName;
  final String? statusName;
  final String? statusColor;
  final String? address;
  final String? offerName;
  final String? note;
  final int? total;
  final String? date;
  final String? nextCallDate;
  final String? fullName;
  @JsonKey(name: 'statusId') // Added statusId field
  final String? statusId;

  SalesModel({
    required this.id,
    this.customerName,
    this.customerTelephone,
    this.productId,
    this.productName,
    this.statusName,
    this.statusColor,
    this.address,
    this.offerName,
    this.note,
    this.total,
    this.date,
    this.nextCallDate,
    this.fullName,
    this.statusId,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) =>
      _$SalesModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalesModelToJson(this);
}