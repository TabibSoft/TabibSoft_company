import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/sales/data/model/paginated_sales_model.dart';

class SalesRepository {
  final ApiService _apiService;

  SalesRepository(this._apiService);

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
}