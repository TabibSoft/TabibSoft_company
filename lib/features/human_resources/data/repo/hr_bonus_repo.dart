import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_bonus_type_model.dart';

class HrBonusRepository {
  final ApiService _apiService;

  HrBonusRepository(this._apiService);

  Future<Either<ServerFailure, List<HrBonusTypeModel>>> getBonuses() async {
    try {
      final response = await _apiService.getHrBonuses();
      return Right(response.data);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
