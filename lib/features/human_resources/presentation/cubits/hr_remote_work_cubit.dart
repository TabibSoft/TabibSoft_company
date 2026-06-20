import 'package:bloc/bloc.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/create_hr_remote_work_request_model.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_remote_work_repo.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_remote_work_state.dart';

class HrRemoteWorkCubit extends Cubit<HrRemoteWorkState> {
  final HrRemoteWorkRepository _repository;

  HrRemoteWorkCubit(this._repository) : super(HrRemoteWorkState.initial());

  Future<void> fetchRemoteWorkRequests() async {
    emit(HrRemoteWorkState.loadingRequests(
      currentRequests: state.requests,
      selectedRequest: state.selectedRequest,
    ));
    final result = await _repository.getMyRemoteWorkRequests();
    result.fold(
      (failure) => emit(HrRemoteWorkState.error(
        failure,
        currentRequests: state.requests,
        selectedRequest: state.selectedRequest,
      )),
      (requests) => emit(HrRemoteWorkState.requestsLoaded(
        requests,
        selectedRequest: state.selectedRequest,
      )),
    );
  }

  Future<void> fetchRemoteWorkRequestById(String id) async {
    emit(HrRemoteWorkState.loadingRequestDetail(
      currentRequests: state.requests,
      selectedRequest: state.selectedRequest,
    ));
    final result = await _repository.getRemoteWorkRequestById(id);
    result.fold(
      (failure) => emit(HrRemoteWorkState.error(
        failure,
        currentRequests: state.requests,
        selectedRequest: state.selectedRequest,
      )),
      (request) => emit(HrRemoteWorkState.requestDetailLoaded(
        request,
        currentRequests: state.requests,
      )),
    );
  }

  Future<void> submitRemoteWork(CreateHrRemoteWorkRequestModel request) async {
    emit(HrRemoteWorkState.submitting(
      state.requests,
      state.selectedRequest,
    ));
    final result = await _repository.submitRemoteWork(request);
    result.fold(
      (failure) => emit(HrRemoteWorkState.error(
        failure,
        currentRequests: state.requests,
        selectedRequest: state.selectedRequest,
      )),
      (_) async {
        emit(HrRemoteWorkState.submitSuccess(
          state.requests,
          state.selectedRequest,
        ));
        await fetchRemoteWorkRequests();
      },
    );
  }
}
