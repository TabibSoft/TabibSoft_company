import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_category_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';

enum CustomerStatus { initial, loading, success, failure }

class CustomerState extends Equatable {
  final CustomerStatus status;
  final List<CustomerModel> customers;
  final List<ProblemModel> techSupportIssues;
  final ProblemModel? selectedProblem;
  final List<ProblemStatusModel> problemStatusList;
  final String? errorMessage;
  final bool isProblemAdded;
  final String? selectedStatus;
  final ProblemModel? newlyAddedIssue; 
  final DateTime? newlyAddedIssueTime; 
  final List<ProblemStatusModel> sitiuationList;
  final List<ProblemCategoryModel> problemCategories;


  const CustomerState({
    this.status = CustomerStatus.initial,
    this.customers = const [],
    this.techSupportIssues = const [],
    this.selectedProblem,
    this.problemStatusList = const [],
    this.errorMessage,
    this.isProblemAdded = false,
    this.selectedStatus,
    this.newlyAddedIssue,
    this.newlyAddedIssueTime,
    this.sitiuationList = const [],
    this.problemCategories = const [],
  });

  CustomerState copyWith({
    CustomerStatus? status,
    List<CustomerModel>? customers,
    List<ProblemModel>? techSupportIssues,
    ProblemModel? selectedProblem,
    List<ProblemStatusModel>? problemStatusList,
    String? errorMessage,
    bool? isProblemAdded,
    String? selectedStatus,
    ProblemModel? newlyAddedIssue,
    DateTime? newlyAddedIssueTime,
     List<ProblemStatusModel>? sitiuationList,
    List<ProblemCategoryModel>? problemCategories,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      techSupportIssues: techSupportIssues ?? this.techSupportIssues,
      selectedProblem: selectedProblem ?? this.selectedProblem,
      problemStatusList: problemStatusList ?? this.problemStatusList,
      errorMessage: errorMessage ?? this.errorMessage,
      isProblemAdded: isProblemAdded ?? this.isProblemAdded,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      newlyAddedIssue: newlyAddedIssue ?? this.newlyAddedIssue,
      newlyAddedIssueTime: newlyAddedIssueTime ?? this.newlyAddedIssueTime,
      sitiuationList: sitiuationList ?? this.sitiuationList,
      problemCategories: problemCategories ?? this.problemCategories,
    );
  }

  @override
  List<Object?> get props => [
        status,
        customers,
        techSupportIssues,
        selectedProblem,
        problemStatusList,
        errorMessage,
        isProblemAdded,
        selectedStatus,
        newlyAddedIssue,
        newlyAddedIssueTime,
      ];
}

