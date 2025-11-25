// features/visits/presentation/cubit/visit_state.dart


import 'package:tabib_soft_company/features/technical_support/visits/data/models/visit_model.dart';

enum VisitStatus { initial, loading, loaded, error }

class VisitState {
  final VisitStatus status;
  final List<VisitModel> visits;
  final String? errorMessage;

  VisitState({required this.status, this.visits = const [], this.errorMessage});
}

class VisitInitial extends VisitState {
  VisitInitial() : super(status: VisitStatus.initial);
}

class VisitLoading extends VisitState {
  VisitLoading() : super(status: VisitStatus.loading);
}

class VisitLoaded extends VisitState {
  VisitLoaded(List<VisitModel> visits)
      : super(status: VisitStatus.loaded, visits: visits);
}

class VisitError extends VisitState {
  VisitError(String message)
      : super(status: VisitStatus.error, errorMessage: message);
}