// File: features/home/data/repos/sales_details_repo.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/notes/sales_detail_model.dart';

class SalesDetailsRepository {
  final ApiService _apiService;

  SalesDetailsRepository(this._apiService);

  Future<Either<ServerFailure, SalesDetailModel>> getDealDetailById({
    required String id,
  }) async {
    try {
      final response = await _apiService.getDealDetailById(id: id);
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}