import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/add_customer/product_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/product_state.dart';
class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _productRepository;

  ProductCubit(this._productRepository) : super(const ProductState());

  Future<void> fetchProducts() async {
    emit(state.copyWith(status: ProductStatus.loading));
    final result = await _productRepository.fetchProducts();
    result.when(
      failure: (failure) => emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: failure.errMessages,
      )),
      success: (products) => emit(state.copyWith(
        status: ProductStatus.success,
        products: products,
      )),
    );
  }
}