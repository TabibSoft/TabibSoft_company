import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_labor_law_model.dart';

class HrLaborLawRepository {
  const HrLaborLawRepository(this._apiService);

  final ApiService _apiService;

  Future<Either<ServerFailure, HrLaborLawResponseModel>>
      getEgyptianLaborLaws() async {
    try {
      final response = await _apiService.getEgyptianLaborLaws();
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
