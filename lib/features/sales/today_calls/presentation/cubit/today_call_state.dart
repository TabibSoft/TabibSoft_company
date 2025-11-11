

import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/sales/today_calls/data/models/today_call_model.dart';

enum TodayCallsStatus {
  initial,
  loading,
  loaded,
  error,
}

class TodayCallsState extends Equatable {
  final TodayCallsStatus status;
  final List<TodayCallModel> calls;
  final String? errorMessage;

  const TodayCallsState({
    this.status = TodayCallsStatus.initial,
    this.calls = const [],
    this.errorMessage,
  });

  TodayCallsState copyWith({
    TodayCallsStatus? status,
    List<TodayCallModel>? calls,
    String? errorMessage,
  }) {
    return TodayCallsState(
      status: status ?? this.status,
      calls: calls ?? this.calls,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, calls, errorMessage];
}
