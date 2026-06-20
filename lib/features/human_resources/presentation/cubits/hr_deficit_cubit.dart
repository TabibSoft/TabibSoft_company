import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_deficit_repo.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_deficit_state.dart';

class HrDeficitCubit extends Cubit<HrDeficitState> {
  final HrDeficitRepository _repository;

  HrDeficitCubit(this._repository) : super(HrDeficitState.initial());

  Future<void> fetchDeficits() async {
    emit(HrDeficitState.loading(currentDeficits: state.deficits));

    final result = await _repository.getDeficits();
    result.fold(
      (failure) => emit(
        HrDeficitState.error(failure, currentDeficits: state.deficits),
      ),
      (deficits) => emit(HrDeficitState.loaded(deficits)),
    );
  }
}
