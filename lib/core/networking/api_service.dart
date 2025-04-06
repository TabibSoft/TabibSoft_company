import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_model.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_req.dart';
import 'api_constants.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiConstants.apiBaseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

 @POST(ApiConstants.login)
  Future<LoginModel> login(@Body() LoginRequest request);
}