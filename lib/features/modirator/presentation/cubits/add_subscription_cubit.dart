import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/modirator/data/repo/add_subscription_repo.dart';
import '../../data/models/add_subscription_model.dart';

part 'add_subscription_state.dart';

class AddSubscriptionCubit extends Cubit<AddSubscriptionState> {
  final SubscriptionRepository repository;

  AddSubscriptionCubit(this.repository) : super(const AddSubscriptionState());

  Future<void> addSubscription(AddSubscriptionModel model) async {
    emit(state.copyWith(status: AddSubscriptionStatus.loading));
    try {
      await repository.addSubscription(model);
      emit(state.copyWith(status: AddSubscriptionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AddSubscriptionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void reset() {
    emit(const AddSubscriptionState());
  }
}