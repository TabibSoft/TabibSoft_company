import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customization/add_customization_request_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/customization_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customization/add_customization_state.dart';

class AddCustomizationCubit extends Cubit<AddCustomizationState> {
  final CustomizationRepository _repository;

  AddCustomizationCubit(this._repository) : super(AddCustomizationInitial());

  Future<void> addCustomization(AddCustomizationRequestModel request) async {
    emit(AddCustomizationLoading());
    final result = await _repository.addCustomization(request);
    result.when(
      success: (_) => emit(AddCustomizationSuccess()),
      failure: (error) => emit(AddCustomizationFailure(error.errMessages)),
    );
  }
}
