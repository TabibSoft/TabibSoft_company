// lib/features/sales/subscription/presentation/cubit/payment_method_state.dart

// part of 'payment_method_cubit.dart';

import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/modirator/data/models/payment_method_model.dart';

enum PaymentMethodStatus { initial, loading, success, failure }

class PaymentMethodState extends Equatable {
  final PaymentMethodStatus status;
  final List<PaymentMethodModel> paymentMethods;
  final String? errorMessage;

  const PaymentMethodState({
    this.status = PaymentMethodStatus.initial,
    this.paymentMethods = const [],
    this.errorMessage,
  });

  PaymentMethodState copyWith({
    PaymentMethodStatus? status,
    List<PaymentMethodModel>? paymentMethods,
    String? errorMessage,
  }) {
    return PaymentMethodState(
      status: status ?? this.status,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, paymentMethods, errorMessage];
}