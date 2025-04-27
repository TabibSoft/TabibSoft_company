import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/sales/data/model/measurement_done/measurement_done_model.dart';

class InstallationRepository {
  final ApiService _apiService;

  InstallationRepository(this._apiService);

  Future<Either<ServerFailure, void>> makeMeasurementDone(
      MeasurementDoneDto dto) async {
    try {
      // تغليف البيانات داخل حقل measurementDone
      final body = {'measurementDone': dto.toJson()};
      await _apiService.makeMeasurementDone(body);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}