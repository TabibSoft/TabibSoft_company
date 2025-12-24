import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_result.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/task_details_model.dart';

class TaskRepository {
  final ApiService _apiService;
  static const _tasksCacheKey = 'cached_programmer_tasks';

  TaskRepository(this._apiService);

  Future<ApiResult<List<CustomizationTaskModel>>> getAllTasks() async {
    try {
      final response = await _apiService.getAllProgrammerTasks();

      // حفظ فى الكاش
      try {
        final jsonString = jsonEncode(response.map((e) => e.toJson()).toList());
        await CacheHelper.saveData(key: _tasksCacheKey, value: jsonString);
      } catch (e) {
        // فشل الحفظ فى الكاش ليس حرجاً
      }

      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

  /// جلب البيانات المخبأة محلياً
  List<CustomizationTaskModel>? getCachedTasks() {
    try {
      final jsonString = CacheHelper.getString(key: _tasksCacheKey);
      if (jsonString.isEmpty) return null;

      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => CustomizationTaskModel.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<ApiResult<TaskDetailsModel>> getTaskById(String id) async {
    try {
      final response = await _apiService.getProgrammerTaskById(id);
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }
}
