// New File: features/home/presentation/cubits/update_status_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/repos/update_status_repo.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/update/update_status_state.dart';

class UpdateStatusCubit extends Cubit<UpdateStatusState> {
  final UpdateStatusRepo _repo;

  UpdateStatusCubit(this._repo) : super(const UpdateStatusState.initial());

  Future<void> changeStatus({
    required String measurementId,
    required String statusId,
  }) async {
    emit(const UpdateStatusState.loading());

    final result = await _repo.changeStatus(
      measurementId: measurementId,
      statusId: statusId,
    );

    result.fold(
      (failure) {
        print('Error: ${failure.errMessages}');  // أضف ده للـ debug
        emit(UpdateStatusState.error(failure));
      },
      (_) => emit(const UpdateStatusState.success()),
    );
  }
}