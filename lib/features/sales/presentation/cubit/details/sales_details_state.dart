import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/sales/data/model/details/sales_details_model.dart';

enum SalesDetailStatus { initial, loading, success, failure }

class SalesDetailState extends Equatable {
  final SalesDetailStatus status;
  final SalesDetailModel? detail;
  final String? errorMessage;

  const SalesDetailState({
    this.status = SalesDetailStatus.initial,
    this.detail,
    this.errorMessage,
  });

  const SalesDetailState.initial() : this(status: SalesDetailStatus.initial);
  const SalesDetailState.loading() : this(status: SalesDetailStatus.loading);
  const SalesDetailState.success(SalesDetailModel detail)
      : this(status: SalesDetailStatus.success, detail: detail);
  const SalesDetailState.failure(String errorMessage)
      : this(status: SalesDetailStatus.failure, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, detail, errorMessage];
}
