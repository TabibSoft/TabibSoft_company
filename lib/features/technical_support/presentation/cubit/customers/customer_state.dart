import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/add_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';

enum CustomerStatus { initial, loading, success, failure }

class CustomerState extends Equatable {
  final CustomerStatus status;
  final List<CustomerModel> customers;
  final List<ProblemModel> techSupportIssues;
  final ProblemModel? selectedProblem;
  final String? errorMessage;
  final List<ProblemStatusModel> problemStatusList;
  final List<EngineerModel> engineers;
  final String? selectedStatus;
  final bool isProblemAdded; // حقل جديد للإشارة إلى نجاح إضافة المشكلة

  const CustomerState({
    this.status = CustomerStatus.initial,
    this.customers = const [],
    this.techSupportIssues = const [],
    this.selectedProblem,
    this.errorMessage,
    this.problemStatusList = const [],
    this.engineers = const [],
    this.selectedStatus,
    this.isProblemAdded = false,
  });

  CustomerState copyWith({
    CustomerStatus? status,
    List<CustomerModel>? customers,
    List<ProblemModel>? techSupportIssues,
    ProblemModel? selectedProblem,
    String? errorMessage,
    List<ProblemStatusModel>? problemStatusList,
    List<EngineerModel>? engineers,
    String? selectedStatus,
    bool? isProblemAdded,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      techSupportIssues: techSupportIssues ?? this.techSupportIssues,
      selectedProblem: selectedProblem ?? this.selectedProblem,
      errorMessage: errorMessage ?? this.errorMessage,
      problemStatusList: problemStatusList ?? this.problemStatusList,
      engineers: engineers ?? this.engineers,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isProblemAdded: isProblemAdded ?? this.isProblemAdded,
    );
  }

  @override
  List<Object?> get props => [
        status,
        customers,
        techSupportIssues,
        selectedProblem,
        errorMessage,
        problemStatusList,
        engineers,
        selectedStatus,
        isProblemAdded,
      ];
}
