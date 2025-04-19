import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/sales/data/model/paginated_sales_model.dart';
import 'package:tabib_soft_company/features/sales/data/model/details/sales_details_model.dart';

class SalesDetailsRepository {
  final ApiService _apiService;

  SalesDetailsRepository(this._apiService);

  /// Fetches a paginated list of measurements.
  Future<Either<ServerFailure, PaginatedSales>> getAllMeasurements({
    int page = 1,
    int pageSize = 10,
    String? statusId,
  }) async {
    try {
      final response = await _apiService.getAllMeasurements(
        page: page,
        pageSize: pageSize,
        statusId: statusId,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  /// Fetches the details of a single deal by its [id].
  Future<Either<ServerFailure, SalesDetailModel>> getDealDetailById(
      String id) async {
    try {
      // Now that ApiService.getDealDetailById() returns a SalesDetailModel,
      // we can forward it directly.
      final SalesDetailModel detail =
          await _apiService.getDealDetailById(id: id);
      return Right(detail);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
