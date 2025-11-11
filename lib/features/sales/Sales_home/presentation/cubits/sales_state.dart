

import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/filter/status_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/paginated_sales_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/product_model.dart';

enum SalesStatus { initial, loading, loaded, loadingMore, error }

class SalesState {
  final SalesStatus status;
  final List<SalesModel> measurements;
  final List<ProductModel> products;
  final List<StatusModel> statuses;
  final int currentPage;
  final int totalPages;
  final ServerFailure? failure;

  const SalesState._({
    required this.status,
    this.measurements = const [],
    this.products = const [],
    this.statuses = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.failure,
  });

  const SalesState.initial() : this._(status: SalesStatus.initial);
  const SalesState.loading() : this._(status: SalesStatus.loading);
  const SalesState.loadingMore(
      List<SalesModel> measurements,
      int currentPage,
      int totalPages,
      List<ProductModel> products,
      List<StatusModel> statuses)
      : this._(
            status: SalesStatus.loadingMore,
            measurements: measurements,
            currentPage: currentPage,
            totalPages: totalPages,
            products: products,
            statuses: statuses);
  const SalesState.loaded(
      List<SalesModel> measurements,
      int currentPage,
      int totalPages,
      List<ProductModel> products,
      List<StatusModel> statuses)
      : this._(
            status: SalesStatus.loaded,
            measurements: measurements,
            currentPage: currentPage,
            totalPages: totalPages,
            products: products,
            statuses: statuses);
  const SalesState.error(ServerFailure failure)
      : this._(status: SalesStatus.error, failure: failure);

  SalesState copyWith({
    SalesStatus? status,
    List<SalesModel>? measurements,
    List<ProductModel>? products,
    List<StatusModel>? statuses,
    int? currentPage,
    int? totalPages,
    ServerFailure? failure,
  }) {
    return SalesState._(
      status: status ?? this.status,
      measurements: measurements ?? this.measurements,
      products: products ?? this.products,
      statuses: statuses ?? this.statuses,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      failure: failure ?? this.failure,
    );
  }
}