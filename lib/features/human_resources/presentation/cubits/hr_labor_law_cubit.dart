import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_labor_law_repo.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_labor_law_state.dart';

class HrLaborLawCubit extends Cubit<HrLaborLawState> {
  HrLaborLawCubit(this._repository) : super(HrLaborLawState.initial());

  final HrLaborLawRepository _repository;

  Future<void> fetchLaborLaws() async {
    emit(HrLaborLawState.loading(currentResponse: state.response));

    final result = await _repository.getEgyptianLaborLaws();

    result.fold(
      (failure) => emit(
        HrLaborLawState.error(
          failure,
          currentResponse: state.response,
        ),
      ),
      (response) => emit(HrLaborLawState.loaded(response)),
    );
  }
}
