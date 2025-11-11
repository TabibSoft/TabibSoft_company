import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/notes/add_note_model.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/repos/notes/add_note_repository.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/presentation/cubits/notes/add_note_state.dart';
class AddNoteCubit extends Cubit<AddNoteState> {
  final AddNoteRepository _addNoteRepository;

  AddNoteCubit(this._addNoteRepository) : super(const AddNoteState.initial());

  Future<void> addNote(AddNoteDto dto) async {
    emit(const AddNoteState.loading());
    final result = await _addNoteRepository.addNote(dto);
    result.fold(
      (failure) => emit(AddNoteState.failure(failure.errMessages)),
      (_) => emit(const AddNoteState.success()),
    );
  }
}