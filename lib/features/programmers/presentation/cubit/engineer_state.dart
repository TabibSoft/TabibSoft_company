import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';

enum EngineerStatus { initial, loading, success, failure }

class EngineerState extends Equatable {
  final EngineerStatus status;
  final List<EngineerModel> engineers;
  final String? errorMessage;

  const EngineerState({
    this.status = EngineerStatus.initial,
    this.engineers = const [],
    this.errorMessage,
  });

  EngineerState copyWith({
    EngineerStatus? status,
    List<EngineerModel>? engineers,
    String? errorMessage,
  }) {
    return EngineerState(
      status: status ?? this.status,
      engineers: engineers ?? this.engineers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, engineers, errorMessage];
}

