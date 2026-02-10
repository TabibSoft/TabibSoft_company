import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/sales/sales_admin/data/models/requirement_model.dart';

enum RequirementsStatus { initial, loading, loaded, error, loadingMore }

class RequirementsState extends Equatable {
  final RequirementsStatus status;
  final List<RequirementReport> requirements;
  final List<SalesPerson> salesPersons;
  final List<StatusCount> statusCounts;
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final String? errorMessage;

  const RequirementsState({
    this.status = RequirementsStatus.initial,
    this.requirements = const [],
    this.salesPersons = const [],
    this.statusCounts = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalRecords = 0,
    this.errorMessage,
  });

  RequirementsState copyWith({
    RequirementsStatus? status,
    List<RequirementReport>? requirements,
    List<SalesPerson>? salesPersons,
    List<StatusCount>? statusCounts,
    int? currentPage,
    int? totalPages,
    int? totalRecords,
    String? errorMessage,
  }) {
    return RequirementsState(
      status: status ?? this.status,
      requirements: requirements ?? this.requirements,
      salesPersons: salesPersons ?? this.salesPersons,
      statusCounts: statusCounts ?? this.statusCounts,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        requirements,
        salesPersons,
        statusCounts,
        currentPage,
        totalPages,
        totalRecords,
        errorMessage,
      ];
}
