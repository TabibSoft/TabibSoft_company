import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_deficit_type_model.dart';

enum HrDeficitStatus { initial, loading, loaded, error }

class HrDeficitState {
  final HrDeficitStatus status;
  final List<HrDeficitTypeModel> deficits;
  final ServerFailure? failure;

  const HrDeficitState._({
    required this.status,
    this.deficits = const [],
    this.failure,
  });

  factory HrDeficitState.initial() =>
      const HrDeficitState._(status: HrDeficitStatus.initial);

  factory HrDeficitState.loading(
          {List<HrDeficitTypeModel> currentDeficits = const []}) =>
      HrDeficitState._(
          status: HrDeficitStatus.loading, deficits: currentDeficits);

  factory HrDeficitState.loaded(List<HrDeficitTypeModel> deficits) =>
      HrDeficitState._(status: HrDeficitStatus.loaded, deficits: deficits);

  factory HrDeficitState.error(ServerFailure failure,
          {List<HrDeficitTypeModel> currentDeficits = const []}) =>
      HrDeficitState._(
        status: HrDeficitStatus.error,
        deficits: currentDeficits,
        failure: failure,
      );
}
