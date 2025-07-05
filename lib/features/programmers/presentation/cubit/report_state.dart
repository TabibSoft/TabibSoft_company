import 'package:equatable/equatable.dart';

enum ReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  final ReportStatus status;
  final String? errorMessage;

  const ReportState({
    this.status = ReportStatus.initial,
    this.errorMessage,
  });

  ReportState copyWith({
    ReportStatus? status,
    String? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}