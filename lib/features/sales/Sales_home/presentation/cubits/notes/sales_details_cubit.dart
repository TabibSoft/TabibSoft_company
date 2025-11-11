// File: features/home/presentation/cubits/sales_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/repos/notes/sales_details_repo.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/sales_details_state.dart';

class SalesDetailsCubit extends Cubit<SalesDetailsState> {
  final SalesDetailsRepository _salesDetailsRepository;

  SalesDetailsCubit(this._salesDetailsRepository) : super(const SalesDetailsState.initial());

  Future<void> fetchDealDetails({
    required String id,
  }) async {
    emit(const SalesDetailsState.loading());
    final result = await _salesDetailsRepository.getDealDetailById(id: id);
    result.fold(
      (failure) => emit(SalesDetailsState.error(failure)),
      (detail) => emit(SalesDetailsState.loaded(detail)),
    );
  }
}