import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_labor_law_model.dart';

enum HrLaborLawStatus {
  initial,
  loading,
  loaded,
  error,
}

class HrLaborLawState {
  const HrLaborLawState._({
    required this.status,
    this.response,
    this.failure,
  });

  final HrLaborLawStatus status;
  final HrLaborLawResponseModel? response;
  final ServerFailure? failure;

  factory HrLaborLawState.initial() => const HrLaborLawState._(
        status: HrLaborLawStatus.initial,
      );

  factory HrLaborLawState.loading({HrLaborLawResponseModel? currentResponse}) =>
      HrLaborLawState._(
        status: HrLaborLawStatus.loading,
        response: currentResponse,
      );

  factory HrLaborLawState.loaded(HrLaborLawResponseModel response) =>
      HrLaborLawState._(
        status: HrLaborLawStatus.loaded,
        response: response,
      );

  factory HrLaborLawState.error(
    ServerFailure failure, {
    HrLaborLawResponseModel? currentResponse,
  }) =>
      HrLaborLawState._(
        status: HrLaborLawStatus.error,
        response: currentResponse,
        failure: failure,
      );
}
