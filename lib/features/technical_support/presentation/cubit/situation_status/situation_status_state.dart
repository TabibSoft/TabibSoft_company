import 'package:tabib_soft_company/features/technical_support/data/model/customization/situation_status_model.dart';

abstract class SituationStatusState {}

class SituationStatusInitial extends SituationStatusState {}

class SituationStatusLoading extends SituationStatusState {}

class SituationStatusSuccess extends SituationStatusState {
  final List<SituationStatusModel> statuses;

  SituationStatusSuccess(this.statuses);
}

class SituationStatusFailure extends SituationStatusState {
  final String errorMessage;

  SituationStatusFailure(this.errorMessage);
}
