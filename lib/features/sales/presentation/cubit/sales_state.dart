import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/sales/data/model/sales_model.dart';

enum SalesStatus { initial, loading, loaded, error }

class SalesState {
  final SalesStatus status;
  final List<SalesModel>? measurements;
  final ServerFailure? failure;

  const SalesState._({
    required this.status,
    this.measurements,
    this.failure,
  });

  const SalesState.initial() : this._(status: SalesStatus.initial);
  const SalesState.loading() : this._(status: SalesStatus.loading);
  const SalesState.loaded(List<SalesModel> measurements)
      : this._(status: SalesStatus.loaded, measurements: measurements);
  const SalesState.error(ServerFailure failure)
      : this._(status: SalesStatus.error, failure: failure);

  SalesState copyWith({
    SalesStatus? status,
    List<SalesModel>? measurements,
    ServerFailure? failure,
  }) {
    return SalesState._(
      status: status ?? this.status,
      measurements: measurements ?? this.measurements,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, measurements, failure];

  @override
  String toString() => 'SalesState(status: $status, measurements: $measurements, failure: $failure)';
}

