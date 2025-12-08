import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/models/paginated_visit_response.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/models/note_model.dart';

class VisitRepository {
  final ApiService _apiService;

  VisitRepository(this._apiService);

  Future<PaginatedVisitResponse> getAllVisits({
    int pageNumber = 1,
    int pageSize = 20,
    String? customerId,
    DateTime? date,
    String? searchValue,
  }) async {
    final body = {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (customerId != null) 'customerId': customerId,
      if (date != null) 'date': date.toIso8601String(),
      if (searchValue != null) 'searchValue': searchValue,
    };
    return await _apiService.getAllVisits(body);
  }

  Future<void> addVisitDetail({
    required String visitInstallDetailId,
    required String note,
    List<MultipartFile>? images,
  }) async {
    await _apiService.addVisitDetail(
      visitInstallDetailId,
      note,
      images,
    );
  }

  Future<void> editVisitDetail({
    required String visitInstallDetailId,
    required String note,
    List<MultipartFile>? images,
    List<String>? existingImageUrls,
  }) async {
    final formData = FormData.fromMap({
      'VisitInstallDetailId': visitInstallDetailId,
      'Note': note,
      if (images != null && images.isNotEmpty) 'Images': images,
      if (existingImageUrls != null && existingImageUrls.isNotEmpty)
        'ExistingImageUrls': existingImageUrls,
    });
    await _apiService.editVisitDetail(formData);
  }

  Future<void> makeVisitDone({required String visitId}) async {
    await _apiService.makeVisitDone(visitId: visitId);
  }

  // إضافة دوال الملاحظات
  Future<NoteModel> addNote({
    required String visitInstallId,
    required String note,
  }) async {
    final request = AddNoteRequest(
      visitInstallId: visitInstallId,
      note: note,
    );
    return await _apiService.addNote(request);
  }

  Future<void> deleteNote({required String noteId}) async {
    await _apiService.deleteNote(id: noteId);
  }

  Future<void> makeNoteRead({required String noteId}) async {
    await _apiService.makeNoteRead(id: noteId);
  }
}
