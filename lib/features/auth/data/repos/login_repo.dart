import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/export.dart';
import 'package:tabib_soft_company/features/auth/export.dart';

class LoginReposetory {
  final ApiService _apiService;

  LoginReposetory(this._apiService);

  Future<ApiResult<LoginResponse>> login({
    required String email,
    required String password,
    required String dKey,
  }) async {
    try {
      final request = LoginRequest(
        email: email,
        password: password,
        dKey: dKey,
      );
      
      final response = await _apiService.login(request);

      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }
}
