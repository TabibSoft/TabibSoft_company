import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_result.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_response.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/create_under_transaction.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';

class CustomerRepository {
  final ApiService _apiService;

  CustomerRepository(this._apiService);

  // Future<ApiResult<AddCustomerResponse>> addCustomer(
  //     CustomerModel customer) async {
  //   try {
  //     final response = await _apiService.addCustomer(customer);
  //     return ApiResult.success(response);
  //   } on DioException catch (e) {
  //     return ApiResult.failure(ServerFailure.fromDioError(e));
  //   }
  // }

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

  // Future<ApiResult<void>> changeProblemStatus({
  //   required String customerSupportId,
  //   String? note,
  //   String? engineerId,
  //   required int problemStatusId,
  //   String? problemTitle,
  //   bool? solvid,
  //   required String customerId,
  // }) async {
  //   try {
  //     await _apiService.changeProblemStatus(
  //       customerSupportId: customerSupportId,
  //       note: note,
  //       engineerId: engineerId,
  //       problemStatusId: problemStatusId,
  //       problemTitle: problemTitle,
  //       solvid: solvid,
  //       customerId: customerId,
  //     );
  //     return ApiResult.success(null);
  //   } on DioException catch (e) {
  //     return ApiResult.failure(ServerFailure.fromDioError(e));
  //   }
  // }

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

  Future<ApiResult<void>> createProblem({
    required String customerId,
    required DateTime dateTime,
    required int problemStatusId,
    String? note,
    String? engineerId,
    String? details,
    String? problemAddress,
    String? phone,
    List<File>? images,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('CustomerId', customerId),
        MapEntry('DateTime', dateTime.toIso8601String()),
        MapEntry('ProblemStatusId', problemStatusId.toString()),
        if (note != null) MapEntry('Note', note),
        if (engineerId != null) MapEntry('EngineerId', engineerId),
        if (details != null) MapEntry('Details', details),
        if (problemAddress != null) MapEntry('ProblemAddress', problemAddress),
        if (phone != null) MapEntry('Phone', phone),
      ]);

      if (images != null && images.isNotEmpty) {
        for (var i = 0; i < images.length; i++) {
          if (images[i].existsSync() && images[i].lengthSync() > 0) {
            print(
                'Adding image: ${images[i].path}, size: ${images[i].lengthSync()} bytes');
            formData.files.add(
              MapEntry(
                'Images',
                await MultipartFile.fromFile(
                  images[i].path,
                  filename: 'image_$i.jpg',
                ),
              ),
            );
          } else {
            print('Invalid image file at index $i: ${images[i].path}');
          }
        }
      }

      await _apiService.createProblem(formData);
      return const ApiResult.success(null);
    } on DioException catch (e) {
      print(
          'DioException in createProblem: ${e.message}, Response: ${e.response?.data}');
      return ApiResult.failure(ServerFailure.fromDioError(e));
    } catch (e) {
      print('Unexpected error in createProblem: $e');
      return ApiResult.failure(ServerFailure('Unexpected error: $e'));
    }
  }
}
