abstract class AddCustomizationState {}

class AddCustomizationInitial extends AddCustomizationState {}

class AddCustomizationLoading extends AddCustomizationState {}

class AddCustomizationSuccess extends AddCustomizationState {}

class AddCustomizationFailure extends AddCustomizationState {
  final String errorMessage;

  AddCustomizationFailure(this.errorMessage);
}
