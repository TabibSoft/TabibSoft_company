import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/sales/data/repo/details/sales_details_repo.dart';
import 'package:tabib_soft_company/features/sales/presentation/cubit/details/sales_details_state.dart';

class SalesDetailCubit extends Cubit<SalesDetailState> {
  final SalesDetailsRepository _salesDetailsRepository;

  SalesDetailCubit(this._salesDetailsRepository) : super(const SalesDetailState.initial());

 Future<void> fetchDealDetail(String id) async {
  emit(const SalesDetailState.loading());
  final result = await _salesDetailsRepository.getDealDetailById(id);
  result.fold(
    (failure) => emit(SalesDetailState.failure(failure.errMessages)),
    (detail) => emit(SalesDetailState.success(detail)),
  );
}}
