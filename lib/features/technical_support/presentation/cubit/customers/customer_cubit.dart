import 'dart:io';
import 'package:bloc/bloc.dart';
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
  final int _pageSize = 30;

  CustomerCubit(this._customerRepository)
      : super(const CustomerState(status: CustomerStatus.initial));

  Future<void> fetchCustomers() async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.getAllCustomers();
    result.when(
      success: (customers) {
        print('Fetched customers: ${customers.map((c) => c.name).toList()}');
        emit(state.copyWith(
          status: CustomerStatus.success,
          customers: customers,
        ));
      },
      failure: (error) {
        print('Error fetching customers: ${error.errMessages}');
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }

  Future<void> fetchTechnicalSupportData(int customerId) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result =
        await _customerRepository.getTechnicalSupportData(customerId);
    result.when(
      success: (problem) {
        print('Fetched technical support data for customerId: $customerId');
        emit(state.copyWith(
          status: CustomerStatus.success,
          selectedProblem: problem,
        ));
      },
      failure: (error) {
        print('Error fetching technical support data: ${error.errMessages}');
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
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
        print('Fetched tech support issues: ${issues.length} items');
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
        print('Error fetching tech support issues: ${error.errMessages}');
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
        print(
            'Fetched problem statuses: ${statusList.map((s) => s.name).toList()}');
        emit(state.copyWith(
          status: CustomerStatus.success,
          problemStatusList: statusList,
        ));
      },
      failure: (error) {
        print('Error fetching problem statuses: ${error.errMessages}');
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }

  Future<void> fetchProblemCategories({int retryCount = 0}) async {
    const maxRetries = 3;
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.getAllProblemCategories();
    result.when(
      success: (categories) {
        print(
            'Fetched problem categories: ${categories.map((c) => c.name).toList()}');
        emit(state.copyWith(
          status: CustomerStatus.success,
          problemCategories: categories,
        ));
      },
      failure: (error) {
        print('Error fetching problem categories: ${error.errMessages}');
        if (retryCount < maxRetries) {
          print('Retrying fetchProblemCategories, attempt ${retryCount + 1}');
          Future.delayed(const Duration(seconds: 1), () {
            fetchProblemCategories(retryCount: retryCount + 1);
          });
        } else {
          emit(state.copyWith(
            status: CustomerStatus.failure,
            errorMessage:
                'فشل في جلب فئات المشكلة بعد $maxRetries محاولات: ${error.errMessages}',
          ));
        }
      },
    );
  }

  Future<void> createUnderTransaction({
    required String customerSupportId,
    required String customerId,
    required String note,
    required int problemStatusId,
  }) async {
    print(
        'Starting createUnderTransaction: customerSupportId=$customerSupportId, customerId=$customerId, note=$note, problemStatusId=$problemStatusId');
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
        print('Searched customers: ${customers.map((c) => c.name).toList()}');
        emit(state.copyWith(
          status: CustomerStatus.success,
          customers: customers,
        ));
      },
      failure: (error) {
        print('Error searching customers: ${error.errMessages}');
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }

  Future<void> createProblem({
    required String customerId,
    required DateTime dateTime,
    required int problemStatusId,
    required String problemCategoryId,
    String? note,
    String? engineerId,
    String? details,
    String? phone,
    List<File>? images,
  }) async {
    print(
        'createProblem called with customerId: $customerId, problemStatusId: $problemStatusId, problemCategoryId: $problemCategoryId');

    // التحقق من صلاحية problemStatusId
    if (state.problemStatusList.isEmpty) {
      await fetchProblemStatus();
    }
    if (!state.problemStatusList.any((s) => s.id == problemStatusId)) {
      print(
          'Invalid problemStatusId: $problemStatusId. Available IDs: ${state.problemStatusList.map((s) => s.id).toList()}');
      emit(state.copyWith(
        status: CustomerStatus.failure,
        errorMessage: 'حالة المشكلة غير صالحة',
        isProblemAdded: false,
      ));
      return;
    }

    // التحقق من صلاحية problemCategoryId
    if (state.problemCategories.isEmpty) {
      await fetchProblemCategories();
    }
    if (!state.problemCategories.any((c) => c.id == problemCategoryId)) {
      print(
          'Invalid problemCategoryId: $problemCategoryId. Available IDs: ${state.problemCategories.map((c) => c.id).toList()}');
      emit(state.copyWith(
        status: CustomerStatus.failure,
        errorMessage: 'فئة المشكلة غير صالحة',
        isProblemAdded: false,
      ));
      return;
    }

    emit(state.copyWith(status: CustomerStatus.loading, isProblemAdded: false));
    final result = await _customerRepository.createProblem(
      customerId: customerId,
      dateTime: dateTime,
      problemStatusId: problemStatusId,
      problemCategoryId: problemCategoryId,
      note: note,
      engineerId: engineerId,
      details: details,
      phone: phone,
      images: images,
    );
    result.when(
      success: (_) {
        print('createProblem succeeded');
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
    print(
        'Pagination reset: currentPage=$_currentPage, hasMoreData=$_hasMoreData');
  }
}
