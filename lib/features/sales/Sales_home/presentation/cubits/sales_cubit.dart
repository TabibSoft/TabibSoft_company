import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/paginated_sales_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/repos/sales_repo.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final SalesRepository _salesRepository;

  SalesCubit(this._salesRepository) : super(const SalesState.initial());

  Future<void> fetchProducts() async {
    final result = await _salesRepository.getAllProducts();
    result.fold(
      (failure) => emit(state.copyWith(products: [])),
      (products) => emit(state.copyWith(products: products)),
    );
  }

  Future<void> fetchStatuses() async {
    final result = await _salesRepository.getAllStatuses();
    result.fold(
      (failure) => emit(state.copyWith(statuses: [])),
      (statuses) => emit(state.copyWith(statuses: statuses)),
    );
  }

  Future<void> fetchMeasurements({
    int page = 1,
    int pageSize = 10,
    String? statusId,
    String? productId,
    String? search,
    String? fromDate,
    String? toDate,
    bool isRefresh = false,
  }) async {
    if (isRefresh || page == 1) {
      emit(state.copyWith(status: SalesStatus.loading));
    } else {
      emit(state.copyWith(
          status: SalesStatus.loadingMore,
          measurements: state.measurements,
          currentPage: state.currentPage,
          totalPages: state.totalPages,
          products: state.products,
          statuses: state.statuses));
    }

    final result = await _salesRepository.getAllMeasurements(
      page: page,
      pageSize: pageSize,
      statusId: statusId,
      productId: productId,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
    );
    result.fold(
      (failure) => emit(SalesState.error(failure)),
      (paginated) {
        List<SalesModel> updatedMeasurements;
        if (isRefresh || page == 1) {
          updatedMeasurements = paginated.items;
        } else {
          updatedMeasurements = [...state.measurements, ...paginated.items];
        }
        emit(SalesState.loaded(
          updatedMeasurements,
          paginated.currentPage,
          paginated.totalPages,
          state.products,
          state.statuses,
        ));
      },
    );
  }
}