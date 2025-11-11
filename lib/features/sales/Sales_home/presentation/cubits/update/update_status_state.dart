// New File: features/home/presentation/cubits/update_status_state.dart
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';

enum UpdateStatusStatus { initial, loading, success, error }

class UpdateStatusState {
  final UpdateStatusStatus status;
  final ServerFailure? failure;

  const UpdateStatusState._({
    required this.status,
    this.failure,
  });

  const UpdateStatusState.initial() : this._(status: UpdateStatusStatus.initial);
  const UpdateStatusState.loading() : this._(status: UpdateStatusStatus.loading);
  const UpdateStatusState.success() : this._(status: UpdateStatusStatus.success);
  const UpdateStatusState.error(ServerFailure failure) : this._(status: UpdateStatusStatus.error, failure: failure);
}