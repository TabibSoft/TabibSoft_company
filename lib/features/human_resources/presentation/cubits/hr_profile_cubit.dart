import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/human_resources/data/repo/hr_profile_repo.dart';
import 'package:tabib_soft_company/features/human_resources/presentation/cubits/hr_profile_state.dart';

class HrProfileCubit extends Cubit<HrProfileState> {
  final HrProfileRepository _repository;

  HrProfileCubit(this._repository) : super(HrProfileState.initial());

  Future<void> fetchHrProfile() async {
    emit(HrProfileState.loading());
    final result = await _repository.getHrProfile();
    result.fold(
      (failure) => emit(HrProfileState.error(failure)),
      (profile) => emit(HrProfileState.loaded(profile)),
    );
  }
}
