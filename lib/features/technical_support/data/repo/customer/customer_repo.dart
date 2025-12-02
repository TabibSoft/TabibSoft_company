import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_result.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/create_under_transaction.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_category_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';

class CustomerRepository {
  final ApiService _apiService;

  CustomerRepository(this._apiService);

  Future<ApiResult<List<CustomerModel>>> getAllCustomers() async {
    try {
      final response = await _apiService.getAllCustomers();
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

  Future<ApiResult<ProblemModel>> getTechnicalSupportData(
      int customerId) async {
    try {
      final response = await _apiService.getTechnicalSupportData(customerId);
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

  Future<ApiResult<List<ProblemModel>>> getAllTechSupport({
    String? customerId,
    String? date,
    String? address,
    int? problem,
    bool? isSearch,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.getAllTechSupport(
        customerId: customerId,
        date: date,
        address: address,
        problem: problem,
        isSearch: isSearch,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      final List<ProblemModel> issues = response.data;
      return ApiResult.success(issues);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

  Future<ApiResult<List<ProblemStatusModel>>> getProblemStatus() async {
    try {
      final response = await _apiService.getProblemStatus();
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

  Future<ApiResult<void>> createUnderTransaction(
      CreateUnderTransaction dto) async {
    try {
      await _apiService.createUnderTransaction(dto);
      return const ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

  Future<ApiResult<List<CustomerModel>>> autoCompleteCustomer(
      String query) async {
    try {
      final response = await _apiService.autoCompleteCustomer(query);
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

  Future<ApiResult<List<ProblemCategoryModel>>>
      getAllProblemCategories() async {
    try {
      final response = await _apiService.getAllProblemCategories();
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

 Future<ApiResult<ProblemModel>> createProblem({
  required String customerId,
  required DateTime dateTime,
  required int problemStatusId,
  required String problemCategoryId,
  String? note,
  String? engineerId,
  String? details,
  String? phone,
  String? problemAddress,   // جديد: عنوان المشكلة
  bool? isUrgent,
  List<File>? images,
}) async {
  try {
    final formData = FormData();

 formData.fields.addAll([
  MapEntry('CustomerId', customerId),
  MapEntry('DateTime', dateTime.toIso8601String()),
  MapEntry('ProblemStatusId', problemStatusId.toString()),
  MapEntry('ProblemCategoryId', problemCategoryId),
  
  // العنوان (شغال 100%)
  if (problemAddress != null && problemAddress.isNotEmpty)
    MapEntry('ProblemAddress', problemAddress),

  // التفاصيل: نرسلها في Note + Details (لأن الـ API يقرأ Note غالبًا)
  if (note != null && note.isNotEmpty) MapEntry('Note', note),
  if (details != null && details.isNotEmpty) ...[
    MapEntry('Note', details),      // الأهم: الـ API يعتمد على Note
    MapEntry('Details', details),   // للتأكد
  ],

  if (engineerId != null && engineerId.isNotEmpty)
    MapEntry('EngineerId', engineerId),
  if (phone != null && phone.isNotEmpty)
    MapEntry('Phone', phone),

  // IsUrgent كـ String
  MapEntry('IsUrgent', isUrgent.toString()), // مهم جدًا: كـ string

  // إذا كان فيه Solvid أو غيره لاحقًا نضيفه
]);
    if (images != null && images.isNotEmpty) {
      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        if (await file.exists() && await file.length() > 0) {
          formData.files.add(
            MapEntry(
              'Images',
              await MultipartFile.fromFile(
                file.path,
                filename: 'image_$i.jpg',
              ),
            ),
          );
        }
      }
    }

    print('Sending CreateProblem FormData: ${formData.fields}');
    print('Images count: ${formData.files.length}');

    final response = await _apiService.createProblem(formData);
    return ApiResult.success(response);
  } on DioException catch (e) {
    print('DioException in createProblem: ${e.message}');
    print('Response: ${e.response?.data}');
    return ApiResult.failure(ServerFailure.fromDioError(e));
  } catch (e) {
    print('Unexpected error: $e');
    return ApiResult.failure(ServerFailure('خطأ غير متوقع: $e'));
  }
}}
