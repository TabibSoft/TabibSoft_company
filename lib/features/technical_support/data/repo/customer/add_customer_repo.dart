import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_result.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/add_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/add_customer_response.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/tech_support_response.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart'; // إضافة الاستيراد

class CustomerRepository {
  final ApiService _apiService;

  CustomerRepository(this._apiService);

  Future<ApiResult<AddCustomerResponse>> addCustomer(CustomerModel customer) async {
    try {
      final response = await _apiService.addCustomer(customer);
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

  Future<ApiResult<List<CustomerModel>>> getAllCustomers() async {
    try {
      final response = await _apiService.getAllCustomers();
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }

  Future<ApiResult<ProblemModel>> getTechnicalSupportData(int customerId) async {
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
    int pageSize = 10,
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
      // استخراج قائمة المشكلات من حقل "data" في TechSupportResponse
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

  Future<ApiResult<void>> changeProblemStatus({
    required String customerSupportId,
    String? note,
    String? engineerId,
    required int problemStatusId,
    String? problemTitle,
    bool? solvid,
    required String customerId,
  }) async {
    try {
      await _apiService.changeProblemStatus(
        customerSupportId: customerSupportId,
        note: note,
        engineerId: engineerId,
        problemStatusId: problemStatusId,
        problemTitle: problemTitle,
        solvid: solvid,
        customerId: customerId,
      );
      return ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }
}
