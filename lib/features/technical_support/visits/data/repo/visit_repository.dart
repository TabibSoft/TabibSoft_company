// features/visits/data/repo/visit_repository.dart
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/core/services/locator/get_it_locator.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/models/visit_model.dart';

class VisitRepository {
  final ApiService _apiService = ServicesLocator.locator<ApiService>();

  Future<List<VisitModel>> getAllVisits({
    int pageNumber = 1,
    int pageSize = 20,
    String searchValue = "",
  }) async {
    final response = await _apiService.getAllVisits({
      "pageNumber": pageNumber,
      "pageSize": pageSize,
      "searchValue": searchValue,
      // يمكن تضيف فلاتر زي customerId أو date لو حابب
    });
    return response.data;
  }


  Future<void> addVisitDetail(FormData formData) async {
  await _apiService.addVisitDetail(formData);
}


  Future<void> makeVisitDone(String visitId) async {
    await _apiService.makeVisitDone(visitId: visitId);
  }
}