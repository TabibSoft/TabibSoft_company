// File: features/home/presentation/cubits/sales_details_state.dart
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/notes/sales_detail_model.dart';

enum SalesDetailsStatus { initial, loading, loaded, error }

class SalesDetailsState {
  final SalesDetailsStatus status;
  final SalesDetailModel? detail;
  final ServerFailure? failure;

  const SalesDetailsState._({
    required this.status,
    this.detail,
    this.failure,
  });

  const SalesDetailsState.initial() : this._(status: SalesDetailsStatus.initial);
  const SalesDetailsState.loading() : this._(status: SalesDetailsStatus.loading);
  const SalesDetailsState.loaded(SalesDetailModel detail)
      : this._(status: SalesDetailsStatus.loaded, detail: detail);
  const SalesDetailsState.error(ServerFailure failure)
      : this._(status: SalesDetailsStatus.error, failure: failure);

  SalesDetailsState copyWith({
    SalesDetailsStatus? status,
    SalesDetailModel? detail,
    ServerFailure? failure,
  }) {
    return SalesDetailsState._(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, detail, failure];

  @override
  String toString() =>
      'SalesDetailsState(status: $status, detail: $detail, failure: $failure)';
}