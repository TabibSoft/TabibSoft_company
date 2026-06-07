import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_leave_request_model.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_leave_type_model.dart';

enum HrLeaveStatus {
  initial,
  loadingTypes,
  typesLoaded,
  loadingRequests,
  requestsLoaded,
  submitting,
  submitSuccess,
  error,
}

class HrLeaveState {
  final HrLeaveStatus status;
  final List<HrLeaveTypeModel> leaveTypes;
  final List<HrLeaveRequestModel> leaveRequests;
  final ServerFailure? failure;

  const HrLeaveState._({
    required this.status,
    this.leaveTypes = const [],
    this.leaveRequests = const [],
    this.failure,
  });

  factory HrLeaveState.initial() => const HrLeaveState._(
        status: HrLeaveStatus.initial,
      );

  factory HrLeaveState.loadingTypes({
    List<HrLeaveTypeModel> currentTypes = const [],
    List<HrLeaveRequestModel> currentRequests = const [],
  }) =>
      HrLeaveState._(
        status: HrLeaveStatus.loadingTypes,
        leaveTypes: currentTypes,
        leaveRequests: currentRequests,
      );

  factory HrLeaveState.typesLoaded(
    List<HrLeaveTypeModel> types, {
    List<HrLeaveRequestModel> currentRequests = const [],
  }) =>
      HrLeaveState._(
        status: HrLeaveStatus.typesLoaded,
        leaveTypes: types,
        leaveRequests: currentRequests,
      );

  factory HrLeaveState.loadingRequests({
    List<HrLeaveTypeModel> currentTypes = const [],
    List<HrLeaveRequestModel> currentRequests = const [],
  }) =>
      HrLeaveState._(
        status: HrLeaveStatus.loadingRequests,
        leaveTypes: currentTypes,
        leaveRequests: currentRequests,
      );

  factory HrLeaveState.requestsLoaded(
    List<HrLeaveRequestModel> requests, {
    List<HrLeaveTypeModel> currentTypes = const [],
  }) =>
      HrLeaveState._(
        status: HrLeaveStatus.requestsLoaded,
        leaveTypes: currentTypes,
        leaveRequests: requests,
      );

  factory HrLeaveState.submitting(
    List<HrLeaveTypeModel> currentTypes,
    List<HrLeaveRequestModel> currentRequests,
  ) =>
      HrLeaveState._(
        status: HrLeaveStatus.submitting,
        leaveTypes: currentTypes,
        leaveRequests: currentRequests,
      );

  factory HrLeaveState.submitSuccess(
    List<HrLeaveTypeModel> currentTypes,
    List<HrLeaveRequestModel> currentRequests,
  ) =>
      HrLeaveState._(
        status: HrLeaveStatus.submitSuccess,
        leaveTypes: currentTypes,
        leaveRequests: currentRequests,
      );

  factory HrLeaveState.error(
    ServerFailure failure, {
    List<HrLeaveTypeModel> currentTypes = const [],
    List<HrLeaveRequestModel> currentRequests = const [],
  }) =>
      HrLeaveState._(
        status: HrLeaveStatus.error,
        failure: failure,
        leaveTypes: currentTypes,
        leaveRequests: currentRequests,
      );
}
