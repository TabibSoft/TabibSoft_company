import 'package:bloc/bloc.dart';
import 'package:tabib_soft_company/features/programmers/data/repo/engineer_repo.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_state.dart';

class EngineerCubit extends Cubit<EngineerState> {
  final EngineerRepository _engineerRepository;

  EngineerCubit(this._engineerRepository) : super(const EngineerState());

  Future<void> fetchEngineers() async {
    emit(state.copyWith(status: EngineerStatus.loading));
    final result = await _engineerRepository.getAllEngineers();
    result.when(
      success: (engineers) {
        emit(state.copyWith(status: EngineerStatus.success, engineers: engineers));
      },
      failure: (error) {
        emit(state.copyWith(status: EngineerStatus.failure, errorMessage: error.errMessages));
      },
    );
  }
}

