import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_deficit_type_model.dart';

class HrDeficitRepository {
  final ApiService _apiService;

  HrDeficitRepository(this._apiService);

  Future<Either<ServerFailure, List<HrDeficitTypeModel>>> getDeficits() async {
    try {
      final response = await _apiService.getHrDeficits();
      return Right(response.data);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
