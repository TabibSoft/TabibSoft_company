import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_result.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/task_details_model.dart';

class TaskRepository {
  final ApiService _apiService;

  TaskRepository(this._apiService);

  Future<ApiResult<List<CustomizationTaskModel>>> getAllTasks() async {
    try {
      final response = await _apiService.getAllProgrammerTasks();
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

  Future<ApiResult<TaskDetailsModel>> getTaskById(String id) async {
    try {
      final response = await _apiService.getProgrammerTaskById(id);
      final task = response; // response is already TaskDetailsModel
      return ApiResult.success(task);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }
}