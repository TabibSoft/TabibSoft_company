import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/create_under_transaction.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/customer/customer_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _customerRepository;
  int _currentPage = 1;
  bool _hasMoreData = true;
  final int _pageSize = 10;

  CustomerCubit(this._customerRepository)
      : super(const CustomerState(status: CustomerStatus.initial));

  Future<void> fetchCustomers() async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.getAllCustomers();
    result.when(
      success: (customers) {
        emit(state.copyWith(
          status: CustomerStatus.success,
          customers: customers,
        ));
      },
      failure: (error) => emit(state.copyWith(
        status: CustomerStatus.failure,
        errorMessage: error.errMessages,
      )),
    );
  }

  // Future<void> addCustomer(CustomerModel customer) async {
  //   emit(state.copyWith(status: CustomerStatus.loading));
  //   final result = await _customerRepository.addCustomer(customer);
  //   result.when(
  //     success: (response) {
  //       emit(state.copyWith(
  //         status: CustomerStatus.success,
  //         customers: [...state.customers, customer],
  //       ));
  //     },
  //     failure: (error) => emit(state.copyWith(
  //       status: CustomerStatus.failure,
  //       errorMessage: error.errMessages,
  //     )),
  //   );
  // }

  Future<void> fetchTechnicalSupportData(int customerId) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result =
        await _customerRepository.getTechnicalSupportData(customerId);
    result.when(
      success: (problem) {
        emit(state.copyWith(
          status: CustomerStatus.success,
          selectedProblem: problem,
        ));
      },
      failure: (error) => emit(state.copyWith(
        status: CustomerStatus.failure,
        errorMessage: error.errMessages,
      )),
    );
  }

  Future<void> fetchTechSupportIssues({
    String? customerId,
    String? date,
    String? address,
    int? problem,
    bool? isSearch,
  }) async {
    if (!_hasMoreData) return;

    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.getAllTechSupport(
      customerId: customerId,
      date: date,
      address: address,
      problem: problem,
      isSearch: isSearch,
      pageNumber: _currentPage,
      pageSize: _pageSize,
    );
    result.when(
      success: (issues) {
        if (issues.length < _pageSize) {
          _hasMoreData = false;
        }
        final updatedIssues = _currentPage == 1
            ? issues
            : [...state.techSupportIssues, ...issues];
        emit(state.copyWith(
          status: CustomerStatus.success,
          techSupportIssues: updatedIssues,
        ));
        _currentPage++;
      },
      failure: (error) {
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }

  Future<void> fetchProblemStatus() async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.getProblemStatus();
    result.when(
      success: (statusList) {
        emit(state.copyWith(
          status: CustomerStatus.success,
          problemStatusList: statusList,
        ));
      },
      failure: (error) => emit(state.copyWith(
        status: CustomerStatus.failure,
        errorMessage: error.errMessages,
      )),
    );
  }

  Future<void> createUnderTransaction({
    required String customerSupportId,
    required String customerId,
    required String note,
    required int problemStatusId,
  }) async {
    print(
        'Starting createUnderTransaction: customerSupportId=$customerSupportId, customerId=$customerId, note=$note');
    emit(state.copyWith(status: CustomerStatus.loading));
    final dto = CreateUnderTransaction(
      customerSupportId: customerSupportId,
      customerId: customerId,
      note: note,
      problemstausId: problemStatusId,
    );
    final result = await _customerRepository.createUnderTransaction(dto);
    result.when(
      success: (_) {
        print('createUnderTransaction succeeded');
        emit(state.copyWith(status: CustomerStatus.success));
        fetchTechSupportIssues();
      },
      failure: (error) {
        print('createUnderTransaction failed: ${error.errMessages}');
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }

  Future<void> searchCustomers(String query) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.autoCompleteCustomer(query);
    result.when(
      success: (customers) {
        emit(state.copyWith(
            status: CustomerStatus.success, customers: customers));
      },
      failure: (error) {
        emit(state.copyWith(
            status: CustomerStatus.failure, errorMessage: error.errMessages));
      },
    );
  }

  Future<void> fetchProblemCategories() async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.getAllProblemCategories();
    result.when(
      success: (categories) {
        emit(state.copyWith(
          status: CustomerStatus.success,
          problemCategories: categories,
        ));
      },
      failure: (error) => emit(state.copyWith(
        status: CustomerStatus.failure,
        errorMessage: error.errMessages,
      )),
    );
  }

  Future<void> createProblem({
    required String customerId,
    required DateTime dateTime,
    required int problemStatusId,
    String? note,
    String? engineerId,
    String? details,
    String? phone,
    List<File>? images,
  }) async {
    print('createProblem called with customerId: $customerId');
    emit(state.copyWith(status: CustomerStatus.loading, isProblemAdded: false));
    final result = await _customerRepository.createProblem(
      customerId: customerId,
      dateTime: dateTime,
      problemStatusId: problemStatusId,
      note: note,
      engineerId: engineerId,
      details: details,
      phone: phone,
      images: images,
    );
    result.when(
      success: (_) {
        print('createProblem succeeded');
        // إنشاء نموذج مشكلة مؤقت مع معرف مؤقت
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        final newIssue = ProblemModel(
          id: tempId,
          customerId: customerId,
          customerName: state.customers
              .firstWhere(
                (c) => c.id == customerId,
                orElse: () => CustomerModel(id: customerId, name: 'غير معروف'),
              )
              .name,
          problemAddress: details ?? note,
          problemDate: dateTime.toIso8601String(),
          problemtype: state.problemStatusList
              .firstWhere(
                (s) => s.id == problemStatusId,
                orElse: () => ProblemStatusModel(id: 0, name: 'غير معروف'),
              )
              .name,
          phone: phone,
          image: images?.isNotEmpty == true ? images!.first.path : null,
        );
        emit(state.copyWith(
          status: CustomerStatus.success,
          isProblemAdded: true,
          newlyAddedIssue: newIssue,
          newlyAddedIssueTime: DateTime.now(),
          techSupportIssues: [newIssue, ...state.techSupportIssues],
        ));
      },
      failure: (error) {
        print('createProblem failed: ${error.errMessages}');
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages,
          isProblemAdded: false,
        ));
      },
    );
  }

  void resetPagination() {
    _currentPage = 1;
    _hasMoreData = true;
  }
}
