import 'package:equatable/equatable.dart';

enum AddNoteStatus { initial, loading, success, failure }

class AddNoteState extends Equatable {
  final AddNoteStatus status;
  final String? errorMessage;

  const AddNoteState({
    required this.status,
    this.errorMessage,
  });

  const AddNoteState.initial() : this(status: AddNoteStatus.initial);
  const AddNoteState.loading() : this(status: AddNoteStatus.loading);
  const AddNoteState.success() : this(status: AddNoteStatus.success);
  const AddNoteState.failure(String errorMessage)
      : this(status: AddNoteStatus.failure, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}
