import 'package:equatable/equatable.dart';

enum AppGateStatus { initial, checking, allowed, blocked, error }

class AppGateState extends Equatable {
  final AppGateStatus status;
  final String? errorMessage;

  const AppGateState({
    this.status = AppGateStatus.initial,
    this.errorMessage,
  });

  static const AppGateState initial = AppGateState(
    status: AppGateStatus.initial,
    errorMessage: null,
  );

  AppGateState copyWith({
    AppGateStatus? status,
    String? errorMessage,
  }) {
    return AppGateState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];

  @override
  String toString() =>
      'AppGateState(status: $status, errorMessage: $errorMessage)';
}
