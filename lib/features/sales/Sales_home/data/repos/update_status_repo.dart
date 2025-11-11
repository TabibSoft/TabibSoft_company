// New File: features/home/data/repos/update_status_repo.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
class UpdateStatusRepo {
  final ApiService _apiService;

  UpdateStatusRepo(this._apiService);

  Future<Either<ServerFailure, void>> changeStatus({
    required String measurementId,
    required String statusId,
  }) async {
    try {
      await _apiService.changeStatus(
        measurementId: measurementId,
        statusId: statusId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}