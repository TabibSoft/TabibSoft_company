import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_result.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customization/add_customization_request_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customization/situation_status_model.dart';

class CustomizationRepository {
  final ApiService _apiService;

  CustomizationRepository(this._apiService);

  Future<ApiResult<void>> addCustomization(
      AddCustomizationRequestModel request) async {
    try {
      final formData = await request.toFormData();
      await _apiService.addCustomization(formData);
      return const ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    } catch (e) {
      return ApiResult.failure(ServerFailure(e.toString()));
    }
  }

  Future<ApiResult<List<SituationStatusModel>>> getSituationStatus() async {
    try {
      final response = await _apiService.getSituationStatus();
      return ApiResult.success(response);
    } on DioException catch (e) {
      return ApiResult.failure(ServerFailure.fromDioError(e));
    } catch (e) {
      return ApiResult.failure(ServerFailure(e.toString()));
    }
  }
}
// CustomerId: 0bdb8d02-fbd6-4405-8a23-08de241caecb
//"customerId""0bdb8d02-fbd6-4405-8a23-08de241caecb"

// CustomerSupportId: c219b67b-9403-4405-fdef-08de45231aea
// "id":             "c219b67b-9403-4405-fdef-08de45231aea",