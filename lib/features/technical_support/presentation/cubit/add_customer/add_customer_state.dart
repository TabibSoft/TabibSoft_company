import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/city_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/government_model.dart';

enum AddCustomerStatus {
  initial,
  loading,
  success,
  failure,
  loadingGovernments,
  loadingCities
}

class AddCustomerState extends Equatable {
  final AddCustomerStatus status;
  final String? errorMessage;
  final bool isCustomerAdded;
  final List<GovernmentModel> governments;
  final List<CityModel> cities;

  const AddCustomerState({
    this.status = AddCustomerStatus.initial,
    this.errorMessage,
    this.isCustomerAdded = false,
    this.governments = const [],
    this.cities = const [],
  });

  AddCustomerState copyWith({
    AddCustomerStatus? status,
    String? errorMessage,
    bool? isCustomerAdded,
    List<GovernmentModel>? governments,
    List<CityModel>? cities,
  }) {
    return AddCustomerState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isCustomerAdded: isCustomerAdded ?? this.isCustomerAdded,
      governments: governments ?? this.governments,
      cities: cities ?? this.cities,
    );
  }

  @override
  List<Object?> get props =>
      [status, errorMessage, isCustomerAdded, governments, cities];
}
