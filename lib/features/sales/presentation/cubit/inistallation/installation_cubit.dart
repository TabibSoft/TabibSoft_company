import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/sales/data/model/measurement_done/measurement_done_model.dart';
import 'package:tabib_soft_company/features/sales/data/repo/installation/installation_repository.dart';
import 'package:tabib_soft_company/features/sales/presentation/cubit/inistallation/installation_state.dart';

class InstallationCubit extends Cubit<InstallationState> {
  final InstallationRepository _installationRepository;

  InstallationCubit(this._installationRepository)
      : super(const InstallationState.initial());

  Future<void> makeMeasurementDone(MeasurementDoneDto dto) async {
    emit(const InstallationState.loading());
    final result = await _installationRepository.makeMeasurementDone(dto);
    result.fold(
      (failure) => emit(InstallationState.failure(failure.errMessages)),
      (_) => emit(const InstallationState.success()),
    );
  }
}
