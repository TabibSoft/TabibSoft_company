import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/create_hr_leave_request_model.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_leave_type_model.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_leave_request_model.dart';

class HrLeaveRepository {
  final ApiService _apiService;

  HrLeaveRepository(this._apiService);

  Future<Either<ServerFailure, List<HrLeaveTypeModel>>> getLeaveTypes() async {
    try {
      final response = await _apiService.getHrLeaveTypes();
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  Future<Either<ServerFailure, List<HrLeaveRequestModel>>> getMyLeaves() async {
    try {
      final response = await _apiService.getMyHrLeaves();
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> createLeave(
    CreateHrLeaveRequestModel request,
  ) async {
    try {
      await _apiService.createHrLeave(request);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
