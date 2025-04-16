import 'package:json_annotation/json_annotation.dart';
import 'package:tabib_soft_company/features/sales/data/model/sales_model.dart';

part 'paginated_sales_model.g.dart';

@JsonSerializable()
class PaginatedSales {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final List<SalesModel> items;

  PaginatedSales({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.items,
  });

  factory PaginatedSales.fromJson(Map<String, dynamic> json) =>
      _$PaginatedSalesFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedSalesToJson(this);
}