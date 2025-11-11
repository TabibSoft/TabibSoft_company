// New File: features/home/presentation/cubits/today_calls/today_calls_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/sales/today_calls/data/repo/today_call_repo.dart';
import 'package:tabib_soft_company/features/sales/today_calls/presentation/cubit/today_call_state.dart';


class TodayCallsCubit extends Cubit<TodayCallsState> {
  final TodayCallsRepository repository;

  TodayCallsCubit(this.repository) : super(const TodayCallsState());

  Future<void> fetchTodayCalls() async {
    emit(state.copyWith(status: TodayCallsStatus.loading));
    final result = await repository.getTodayCalls();
    result.fold(
      (failure) => emit(state.copyWith(
        status: TodayCallsStatus.error,
        errorMessage: failure.errMessages,
      )),
      (calls) => emit(state.copyWith(
        status: TodayCallsStatus.loaded,
        calls: calls,
      )),
    );
  }
}
