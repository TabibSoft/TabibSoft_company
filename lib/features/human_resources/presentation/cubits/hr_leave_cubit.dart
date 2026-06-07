import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/create_hr_leave_request_model.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_leave_repo.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_leave_state.dart';

class HrLeaveCubit extends Cubit<HrLeaveState> {
  final HrLeaveRepository _repository;

  HrLeaveCubit(this._repository) : super(HrLeaveState.initial());

  Future<void> fetchLeaveTypes() async {
    emit(
      HrLeaveState.loadingTypes(
        currentTypes: state.leaveTypes,
        currentRequests: state.leaveRequests,
      ),
    );
    final result = await _repository.getLeaveTypes();
    result.fold(
      (failure) => emit(
        HrLeaveState.error(
          failure,
          currentTypes: state.leaveTypes,
          currentRequests: state.leaveRequests,
        ),
      ),
      (types) => emit(
        HrLeaveState.typesLoaded(
          types,
          currentRequests: state.leaveRequests,
        ),
      ),
    );
  }

  Future<void> fetchMyLeaves() async {
    emit(
      HrLeaveState.loadingRequests(
        currentTypes: state.leaveTypes,
        currentRequests: state.leaveRequests,
      ),
    );
    final result = await _repository.getMyLeaves();
    result.fold(
      (failure) => emit(
        HrLeaveState.error(
          failure,
          currentTypes: state.leaveTypes,
          currentRequests: state.leaveRequests,
        ),
      ),
      (requests) => emit(
        HrLeaveState.requestsLoaded(
          requests,
          currentTypes: state.leaveTypes,
        ),
      ),
    );
  }

  Future<void> createLeave(CreateHrLeaveRequestModel request) async {
    emit(HrLeaveState.submitting(state.leaveTypes, state.leaveRequests));
    final result = await _repository.createLeave(request);
    result.fold(
      (failure) => emit(
        HrLeaveState.error(
          failure,
          currentTypes: state.leaveTypes,
          currentRequests: state.leaveRequests,
        ),
      ),
      (_) => emit(
        HrLeaveState.submitSuccess(state.leaveTypes, state.leaveRequests),
      ),
    );
  }
}
