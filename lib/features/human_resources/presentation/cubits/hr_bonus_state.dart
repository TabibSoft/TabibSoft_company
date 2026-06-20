import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/human_resources/data/models/hr_bonus_type_model.dart';

enum HrBonusStatus { initial, loading, loaded, error }

class HrBonusState {
  final HrBonusStatus status;
  final List<HrBonusTypeModel> bonuses;
  final ServerFailure? failure;

  const HrBonusState._({
    required this.status, 
    this.bonuses = const [],
    this.failure,
  });

  factory HrBonusState.initial() =>
      const HrBonusState._(status: HrBonusStatus.initial);

  factory HrBonusState.loading(
          {List<HrBonusTypeModel> currentBonuses = const []}) =>
      HrBonusState._(status: HrBonusStatus.loading, bonuses: currentBonuses);

  factory HrBonusState.loaded(List<HrBonusTypeModel> bonuses) =>
      HrBonusState._(status: HrBonusStatus.loaded, bonuses: bonuses);

  factory HrBonusState.error(ServerFailure failure,
          {List<HrBonusTypeModel> currentBonuses = const []}) =>
      HrBonusState._(
        status: HrBonusStatus.error,
        bonuses: currentBonuses,
        failure: failure,
      );
}
