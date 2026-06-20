import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_bonus_repo.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_bonus_state.dart';

class HrBonusCubit extends Cubit<HrBonusState> {
  final HrBonusRepository _repository;

  HrBonusCubit(this._repository) : super(HrBonusState.initial());

  Future<void> fetchBonuses() async {
    emit(HrBonusState.loading(currentBonuses: state.bonuses));

    final result = await _repository.getBonuses();
    result.fold(
      (failure) =>
          emit(HrBonusState.error(failure, currentBonuses: state.bonuses)),
      (bonuses) => emit(HrBonusState.loaded(bonuses)),
    );
  }
}
