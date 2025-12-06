// features/visits/presentation/cubit/visit_cubit.dart

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/repo/visit_repository.dart';
import 'visit_state.dart';

class VisitCubit extends Cubit<VisitState> {
  final VisitRepository _repository;

  VisitCubit(this._repository) : super(VisitInitial());

  Future<void> loadVisits({
    int pageNumber = 1,
    int pageSize = 20,
    String search = "",
  }) async {
    emit(VisitLoading());
    try {
      final visits = await _repository.getAllVisits(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchValue: search,
      );
      emit(VisitLoaded(visits));
    } catch (e) {
      emit(VisitError(e.toString()));
    }
  }

 Future<void> addVisitDetail({
  required String visitInstallDetailId,
  required String note,
  List<MultipartFile>? images,
}) async {
  emit(VisitLoading());
  try {
    await _repository.addVisitDetail(
      visitInstallDetailId: visitInstallDetailId,
      note: note,
      images: images,
    );
    await loadVisits();
  } catch (e) {
    emit(VisitError(e.toString()));
    rethrow;
  }
}
  Future<void> completeVisit(String visitId) async {
    try {
      await _repository.makeVisitDone(visitId);
      await loadVisits();
    } catch (e) {
      emit(VisitError("فشل إتمام الزيارة: ${e.toString()}"));
    }
  }
}