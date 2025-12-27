import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'situation_status_state.dart';

class SituationStatusCubit extends Cubit<SituationStatusState> {
  final ApiService _apiService;

  SituationStatusCubit(this._apiService) : super(SituationStatusInitial());

  Future<void> getSituationStatuses() async {
    emit(SituationStatusLoading());
    try {
      final statuses = await _apiService.getSituationStatus();
      emit(SituationStatusSuccess(statuses));
    } catch (e) {
      emit(SituationStatusFailure(e.toString()));
    }
  }
}
