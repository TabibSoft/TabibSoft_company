import 'package:tabib_soft_company/core/networking/api_service.dart';
import '../models/requirement_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';

class RequirementsRepository {
  final ApiService _apiService;

  RequirementsRepository(this._apiService);

  Future<PaginatedRequirements> getRequirementsData(
      Map<String, dynamic> body) async {
    return await _apiService.getRequirementsData(body);
  }

  Future<List<EngineerModel>> getAllEngineers() async {
    return await _apiService.getAllEngineers();
  }

  Future<void> updateAdminNote(Map<String, dynamic> body) async {
    return await _apiService.updateAdminNote(body);
  }
}
