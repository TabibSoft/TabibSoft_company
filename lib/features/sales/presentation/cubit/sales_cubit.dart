import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/sales/data/repo/sales_repo.dart';
import 'package:tabib_soft_company/features/sales/presentation/cubit/sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final SalesRepository _salesRepository;

  SalesCubit(this._salesRepository) : super(const SalesState.initial());

 Future<void> fetchMeasurements({
  int page = 1,
  int pageSize = 10,
  String? statusId,
}) async {
  emit(const SalesState.loading());
  final result = await _salesRepository.getAllMeasurements(
    page: page,
    pageSize: pageSize,
    statusId: statusId,
  );
  result.fold(
    (failure) => emit(SalesState.error(failure)),
    (paginatedMeasurements) => emit(SalesState.loaded(paginatedMeasurements.items)),
  );
}}