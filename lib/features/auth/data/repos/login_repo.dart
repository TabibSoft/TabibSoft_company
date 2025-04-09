import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_model.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_req.dart';

class LoginReposetory {
  final ApiService _apiService;

  LoginReposetory(Dio dio) : _apiService = ApiService(dio);


  Future<LoginModel> login({
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
      return response;
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          throw Exception(errors.join('\n'));
        }
      }
      rethrow;
    }
  }
}
