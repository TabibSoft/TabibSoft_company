import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_result.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/add_customer_model.dart';

class AddCustomerRepository {
  final ApiService _apiService;

  AddCustomerRepository(this._apiService);

  Future<ApiResult<void>> addCustomer(AddCustomerModel customer) async {
    try {
      await _apiService.addCustomer(customer);
      return const ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    }
  }
}