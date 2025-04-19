import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/add_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/add_customer/add_customer_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/add_customer/add_customer_state.dart';

class AddCustomerCubit extends Cubit<AddCustomerState> {
  final AddCustomerRepository _addCustomerRepository;

  AddCustomerCubit(this._addCustomerRepository)
      : super(const AddCustomerState());

  Future<void> addCustomer(AddCustomerModel customer) async {
    emit(state.copyWith(status: AddCustomerStatus.loading));
    final result = await _addCustomerRepository.addCustomer(customer);
    result.when(
      success: (_) {
        emit(state.copyWith(
          status: AddCustomerStatus.success,
          isCustomerAdded: true,
        ));
      },
      failure: (error) {
        emit(state.copyWith(
          status: AddCustomerStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }
}