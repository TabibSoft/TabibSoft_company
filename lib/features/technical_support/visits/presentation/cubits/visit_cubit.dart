import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/repo/visit_repository.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_state.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/models/note_model.dart';

class VisitCubit extends Cubit<VisitState> {
  final VisitRepository _repository;

  VisitCubit(this._repository) : super(const VisitState());

  Future<void> fetchVisits({
    int pageNumber = 1,
    int pageSize = 20,
    String? customerId,
    DateTime? date,
    String? searchValue,
  }) async {
    try {
      emit(state.copyWith(status: VisitStatus.loading));
      
      final response = await _repository.getAllVisits(
        pageNumber: pageNumber,
        pageSize: pageSize,
        customerId: customerId,
        date: date,
        searchValue: searchValue,
      );
      
      emit(state.copyWith(
        status: VisitStatus.loaded,
        visits: response.data ?? [],
        currentPage: response.pageNumber,
        totalPages: response.totalPages,
        hasMore: pageNumber < response.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VisitStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadVisits() => fetchVisits();

  Future<void> addVisitDetail({
    required String visitInstallDetailId,
    required String note,
    List<MultipartFile>? images,
  }) async {
    try {
      await _repository.addVisitDetail(
        visitInstallDetailId: visitInstallDetailId,
        note: note,
        images: images,
      );
      await fetchVisits(pageNumber: state.currentPage);
    } catch (e) {
      emit(state.copyWith(
        status: VisitStatus.error,
        errorMessage: e.toString(),
      ));
      rethrow;
    }
  }

  Future<void> editVisitDetail({
    required String visitInstallDetailId,
    required String note,
    List<MultipartFile>? images,
    List<String>? existingImageUrls,
  }) async {
    try {
      await _repository.editVisitDetail(
        visitInstallDetailId: visitInstallDetailId,
        note: note,
        images: images,
        existingImageUrls: existingImageUrls,
      );
      await fetchVisits(pageNumber: state.currentPage);
    } catch (e) {
      emit(state.copyWith(
        status: VisitStatus.error,
        errorMessage: e.toString(),
      ));
      rethrow;
    }
  }

Future<void> makeVisitDone({required String visitId}) async {
  try {
    await _repository.makeVisitDone(visitId: visitId);
    // إعادة تحميل الزيارات بعد التحديث
    await fetchVisits(pageNumber: state.currentPage);
  } catch (e) {
    emit(state.copyWith(
      status: VisitStatus.error,
      errorMessage: e.toString(),
    ));
    rethrow;
  }
}

  // إضافة دوال الملاحظات
  Future<NoteModel> addNote({
    required String visitInstallId,
    required String note,
  }) async {
    try {
      final result = await _repository.addNote(
        visitInstallId: visitInstallId,
        note: note,
      );
      return result;
    } catch (e) {
      emit(state.copyWith(
        status: VisitStatus.error,
        errorMessage: e.toString(),
      ));
      rethrow;
    }
  }

  Future<void> deleteNote({required String noteId}) async {
    try {
      await _repository.deleteNote(noteId: noteId);
    } catch (e) {
      emit(state.copyWith(
        status: VisitStatus.error,
        errorMessage: e.toString(),
      ));
      rethrow;
    }
  }

  Future<void> makeNoteRead({required String noteId}) async {
    try {
      await _repository.makeNoteRead(noteId: noteId);
    } catch (e) {
      emit(state.copyWith(
        status: VisitStatus.error,
        errorMessage: e.toString(),
      ));
      rethrow;
    }
  }

  void reset() {
    emit(const VisitState());
  }
}
