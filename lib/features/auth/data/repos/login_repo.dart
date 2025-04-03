import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_result.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_model.dart';

class LoginRepository {
  final ApiService apiService;

  LoginRepository({required this.apiService});

 Future<ApiResult<LoginModel>> login({
  required String username,
  required String password,
  required String token,
}) async {
  try {
    final loginModel = await apiService.login(
      {
        'username': username,
        'password': password,
      },
      token,
    );
    return ApiResult.success(loginModel);
  } on DioException catch (e) {
    return ApiResult.failure(ServerFailure.fromDioError(e));
  } catch (error) {
    return ApiResult.failure(ServerFailure(error.toString()));
  }
}
}
