// features/visits/presentation/cubit/visit_cubit.dart
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/visits/data/repo/visit_repository.dart';
import 'package:tabib_soft_company/features/technical_support/visits/presentation/cubits/visit_state.dart';


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

Future<void> makeVisitDone({
  required String visitId,
  String? note,
}) async {
  // في المستقبل هتستدعي API
  // لكن حاليًا بس نعمل refresh للقائمة
  return loadVisits();
}

Future<void> addVisitDetail(FormData formData) async {
  emit(VisitLoading());
  try {
    await _repository.addVisitDetail(formData);
    await loadVisits(); // تحديث القائمة
    emit(VisitLoaded(state.visits)); // أو أي state مناسب
  } catch (e) {
    emit(VisitError(e.toString()));
    rethrow;
  }
}
  Future<void> completeVisit(String visitId) async {
    try {
      await _repository.makeVisitDone(visitId);
      // إعادة تحميل القائمة أو تحديث الحالة محلياً
      await loadVisits();
    } catch (e) {
      emit(VisitError("فشل إتمام الزيارة: ${e.toString()}"));
    }
  }
}