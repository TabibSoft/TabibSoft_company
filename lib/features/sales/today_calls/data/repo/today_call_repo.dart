// File: features/home/data/repos/today_calls_repo.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/sales/today_calls/data/models/today_call_model.dart';

class TodayCallsRepository {
  final ApiService _apiService;

  TodayCallsRepository(this._apiService);

  Future<Either<ServerFailure, List<TodayCallModel>>> getTodayCalls() async {
    try {
      final response = await _apiService.getTodayCalls();
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
