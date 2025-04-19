import 'package:equatable/equatable.dart';

enum AddCustomerStatus { initial, loading, success, failure }

class AddCustomerState extends Equatable {
  final AddCustomerStatus status;
  final String? errorMessage;
  final bool isCustomerAdded;

  const AddCustomerState({
    this.status = AddCustomerStatus.initial,
    this.errorMessage,
    this.isCustomerAdded = false,
  });

  AddCustomerState copyWith({
    AddCustomerStatus? status,
    String? errorMessage,
    bool? isCustomerAdded,
  }) {
    return AddCustomerState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isCustomerAdded: isCustomerAdded ?? this.isCustomerAdded,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, isCustomerAdded];
}