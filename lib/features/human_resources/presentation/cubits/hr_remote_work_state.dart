import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_remote_work_request_model.dart';

enum HrRemoteWorkStatus {
  initial,
  loadingRequests,
  requestsLoaded,
  loadingRequestDetail,
  requestDetailLoaded,
  submitting,
  submitSuccess,
  error,
}

class HrRemoteWorkState {
  final HrRemoteWorkStatus status;
  final List<HrRemoteWorkRequestModel> requests;
  final HrRemoteWorkRequestModel? selectedRequest;
  final ServerFailure? failure;

  const HrRemoteWorkState._({
    required this.status,
    this.requests = const [],
    this.selectedRequest,
    this.failure,
  });

  factory HrRemoteWorkState.initial() => const HrRemoteWorkState._(
        status: HrRemoteWorkStatus.initial,
      );

  factory HrRemoteWorkState.loadingRequests({
    List<HrRemoteWorkRequestModel> currentRequests = const [],
    HrRemoteWorkRequestModel? selectedRequest,
  }) =>
      HrRemoteWorkState._(
        status: HrRemoteWorkStatus.loadingRequests,
        requests: currentRequests,
        selectedRequest: selectedRequest,
      );

  factory HrRemoteWorkState.requestsLoaded(
    List<HrRemoteWorkRequestModel> requests, {
    HrRemoteWorkRequestModel? selectedRequest,
  }) =>
      HrRemoteWorkState._(
        status: HrRemoteWorkStatus.requestsLoaded,
        requests: requests,
        selectedRequest: selectedRequest,
      );

  factory HrRemoteWorkState.loadingRequestDetail({
    List<HrRemoteWorkRequestModel> currentRequests = const [],
    HrRemoteWorkRequestModel? selectedRequest,
  }) =>
      HrRemoteWorkState._(
        status: HrRemoteWorkStatus.loadingRequestDetail,
        requests: currentRequests,
        selectedRequest: selectedRequest,
      );

  factory HrRemoteWorkState.requestDetailLoaded(
    HrRemoteWorkRequestModel request, {
    List<HrRemoteWorkRequestModel> currentRequests = const [],
  }) =>
      HrRemoteWorkState._(
        status: HrRemoteWorkStatus.requestDetailLoaded,
        requests: currentRequests,
        selectedRequest: request,
      );

  factory HrRemoteWorkState.submitting(
    List<HrRemoteWorkRequestModel> currentRequests,
    HrRemoteWorkRequestModel? selectedRequest,
  ) =>
      HrRemoteWorkState._(
        status: HrRemoteWorkStatus.submitting,
        requests: currentRequests,
        selectedRequest: selectedRequest,
      );

  factory HrRemoteWorkState.submitSuccess(
    List<HrRemoteWorkRequestModel> currentRequests,
    HrRemoteWorkRequestModel? selectedRequest,
  ) =>
      HrRemoteWorkState._(
        status: HrRemoteWorkStatus.submitSuccess,
        requests: currentRequests,
        selectedRequest: selectedRequest,
      );

  factory HrRemoteWorkState.error(
    ServerFailure failure, {
    List<HrRemoteWorkRequestModel> currentRequests = const [],
    HrRemoteWorkRequestModel? selectedRequest,
  }) =>
      HrRemoteWorkState._(
        status: HrRemoteWorkStatus.error,
        failure: failure,
        requests: currentRequests,
        selectedRequest: selectedRequest,
      );
}
