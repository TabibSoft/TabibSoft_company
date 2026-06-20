import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/create_hr_remote_work_request_model.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_remote_work_request_model.dart';

class HrRemoteWorkRepository {
  final ApiService _apiService;

  HrRemoteWorkRepository(this._apiService);

  Future<Either<ServerFailure, List<HrRemoteWorkRequestModel>>>
      getMyRemoteWorkRequests() async {
    try {
      final response = await _apiService.getMyRemoteWorkRequests();
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  Future<Either<ServerFailure, HrRemoteWorkRequestModel>>
      getRemoteWorkRequestById(String id) async {
    try {
      final response = await _apiService.getRemoteWorkRequestById(id);
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> submitRemoteWork(
    CreateHrRemoteWorkRequestModel request,
  ) async {
    try {
      await _apiService.submitRemoteWork(request);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
