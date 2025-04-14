import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_result.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';

class EngineerRepository {
  final ApiService _apiService;

  EngineerRepository(this._apiService);

  Future<ApiResult<List<EngineerModel>>> getAllEngineers() async {
    try {
      final response = await _apiService.getAllEngineers();
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }
}

