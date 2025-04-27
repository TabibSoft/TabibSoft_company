import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';

enum InstallationStatus { initial, loading, success, failure }

class InstallationState extends Equatable {
  final InstallationStatus status;
  final String? errorMessage;

  const InstallationState({
    required this.status,
    this.errorMessage,
  });

  const InstallationState.initial() : this(status: InstallationStatus.initial);
  const InstallationState.loading() : this(status: InstallationStatus.loading);
  const InstallationState.success() : this(status: InstallationStatus.success);
  const InstallationState.failure(String errorMessage)
      : this(status: InstallationStatus.failure, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}
