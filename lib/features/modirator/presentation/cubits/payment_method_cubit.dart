// lib/features/sales/subscription/presentation/cubit/payment_method_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/modirator/data/repo/payment_method_repository.dart';
import 'package:tabib_soft_company/features/modirator/presentation/cubits/payment_method_state.dart';
import '../../data/models/payment_method_model.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  final PaymentMethodRepository repository;

  PaymentMethodCubit(this.repository) : super(const PaymentMethodState());

  Future<void> fetchPaymentMethods() async {
    emit(state.copyWith(status: PaymentMethodStatus.loading));
    try {
      final methods = await repository.getPaymentMethods();
      emit(state.copyWith(
        status: PaymentMethodStatus.success,
        paymentMethods: methods,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}