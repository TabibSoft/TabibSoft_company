part of 'add_subscription_cubit.dart';

enum AddSubscriptionStatus { initial, loading, success, failure }

class AddSubscriptionState extends Equatable {
  final AddSubscriptionStatus status;
  final String? errorMessage;

  const AddSubscriptionState({
    this.status = AddSubscriptionStatus.initial,
    this.errorMessage,
  });

  AddSubscriptionState copyWith({
    AddSubscriptionStatus? status,
    String? errorMessage,
  }) {
    return AddSubscriptionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}