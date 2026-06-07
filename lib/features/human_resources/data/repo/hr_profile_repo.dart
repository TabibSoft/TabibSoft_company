import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_profile_model.dart';

class HrProfileRepository {
  final ApiService _apiService;

  HrProfileRepository(this._apiService);

  Future<Either<ServerFailure, HrProfileModel>> getHrProfile() async {
    try {
      final response = await _apiService.getHrProfileMe();
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
