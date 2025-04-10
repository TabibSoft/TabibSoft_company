import 'package:tabib_soft_company/features/technical_support/data/model/customer/add_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';

enum CustomerStatus { initial, loading, success, failure }

class CustomerState {
  final CustomerStatus status;
  final List<CustomerModel> customers;
  final List<ProblemModel> techSupportIssues;
  final ProblemModel? selectedProblem;
  final String? errorMessage;
  final List<ProblemStatusModel> problemStatusList; 
  final String? selectedStatus;

  CustomerState({
    required this.status,
    this.customers = const [],
    this.techSupportIssues = const [],
    this.selectedProblem,
    this.errorMessage,
    this.problemStatusList = const [], 
    this.selectedStatus
  });

  CustomerState copyWith({
    CustomerStatus? status,
    List<CustomerModel>? customers,
    List<ProblemModel>? techSupportIssues,
    ProblemModel? selectedProblem,
    String? errorMessage,
    List<ProblemStatusModel>? problemStatusList,
    String? selectedStatus,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      techSupportIssues: techSupportIssues ?? this.techSupportIssues,
      selectedProblem: selectedProblem ?? this.selectedProblem,
      errorMessage: errorMessage ?? this.errorMessage,
      problemStatusList: problemStatusList ?? this.problemStatusList,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}
