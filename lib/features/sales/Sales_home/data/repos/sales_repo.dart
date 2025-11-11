// Modified File: lib/features/home/data/repos/sales_repo.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/filter/status_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/paginated_sales_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/product_model.dart';
class SalesRepository {
  final ApiService _apiService;

  SalesRepository(this._apiService);

  Future<Either<ServerFailure, PaginatedSales>> getAllMeasurements({
    int page = 1,
    int pageSize = 10,
    String? statusId,
    String? productId,
    String? search,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final response = await _apiService.getAllMeasurements(
        page: page,
        pageSize: pageSize,
        statusId: statusId,
        productId: productId,
        search: search,
        fromDate: fromDate,
        toDate: toDate,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  Future<Either<ServerFailure, List<ProductModel>>> getAllProducts() async {
    try {
      final response = await _apiService.getAllProducts();
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }



  Future<Either<ServerFailure, List<StatusModel>>> getAllStatuses() async {
  try {
    final response = await _apiService.getAllStatuses();
    return Right(response);
  } on DioException catch (e) {
    return Left(ServerFailure.fromDioError(e));
  }
}
}
