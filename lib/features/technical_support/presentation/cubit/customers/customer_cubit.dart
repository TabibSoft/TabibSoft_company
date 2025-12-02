import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/create_under_transaction.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_category_model.dart';
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

  // إعادة تعيين حالة إضافة المشكلة
  void resetProblemAddedFlag() {
    emit(state.copyWith(isProblemAdded: false, newlyAddedIssue: null));
  }

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
      failure: (error) {
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }

  Future<void> fetchTechnicalSupportData(int customerId) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.getTechnicalSupportData(customerId);
    result.when(
      success: (problem) {
        emit(state.copyWith(
          status: CustomerStatus.success,
          selectedProblem: problem,
        ));
      },
      failure: (error) {
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
    if (!_hasMoreData && _currentPage != 1) return;

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
        if (issues.length < _pageSize) _hasMoreData = false;

        final sortedIssues = List<ProblemModel>.from(issues);
        sortedIssues.sort((a, b) {
          final dateA = DateTime.tryParse(a.problemDate ?? '') ?? DateTime(1970);
          final dateB = DateTime.tryParse(b.problemDate ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });

        final updatedIssues = _currentPage == 1
            ? sortedIssues
            : [...state.techSupportIssues, ...sortedIssues];

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
    if (state.problemStatusList.isNotEmpty) return;

    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.getProblemStatus();
    result.when(
      success: (statusList) {
        emit(state.copyWith(
          status: CustomerStatus.success,
          problemStatusList: statusList,
        ));
      },
      failure: (error) {
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }

  Future<void> fetchProblemCategories({int retryCount = 0}) async {
    const maxRetries = 3;
    if (state.problemCategories.isNotEmpty && retryCount == 0) return;

    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.getAllProblemCategories();
    result.when(
      success: (categories) {
        emit(state.copyWith(
          status: CustomerStatus.success,
          problemCategories: categories,
        ));
      },
      failure: (error) {
        if (retryCount < maxRetries) {
          Future.delayed(const Duration(seconds: 1), () {
            fetchProblemCategories(retryCount: retryCount + 1);
          });
        } else {
          emit(state.copyWith(
            status: CustomerStatus.failure,
            errorMessage: 'فشل تحميل فئات المشاكل: ${error.errMessages}',
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
        resetPagination();
        fetchTechSupportIssues();
      },
      failure: (error) {
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
          status: CustomerStatus.success,
          customers: customers,
        ));
      },
      failure: (error) {
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }

  /// إنشاء مشكلة جديدة - محدث بالكامل وفق Swagger
  Future<void> createProblem({
    required String customerId,
    required DateTime dateTime,
    required int problemStatusId,
    required String problemCategoryId,
    required String problemAddress, // عنوان المشكلة (مطلوب للعرض)
    String? note,
    String? engineerId,
    String? details,
    String? phone,
    bool isUrgent = false,
    List<File>? images,
  }) async {
    // تحميل الحالات والفئات إذا لم تكن موجودة
    if (state.problemStatusList.isEmpty) await fetchProblemStatus();
    if (state.problemCategories.isEmpty) await fetchProblemCategories();

    // التحقق من صحة الحالة
    final statusValid = state.problemStatusList.any((s) => s.id == problemStatusId);
    if (!statusValid) {
      emit(state.copyWith(
        status: CustomerStatus.failure,
        errorMessage: 'حالة المشكلة غير صالحة',
        isProblemAdded: false,
      ));
      return;
    }

    // التحقق من صحة الفئة
    final categoryValid = state.problemCategories.any((c) => c.id == problemCategoryId);
    if (!categoryValid) {
      emit(state.copyWith(
        status: CustomerStatus.failure,
        errorMessage: 'فئة المشكلة غير صالحة',
        isProblemAdded: false,
      ));
      return;
    }

    if (problemAddress.trim().isEmpty) {
      emit(state.copyWith(
        status: CustomerStatus.failure,
        errorMessage: 'يرجى كتابة عنوان المشكلة',
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
  problemAddress: problemAddress,
  note: note ?? details,        // ندمج التفاصيل في Note
  details: details,             // ونرسلها كمان
  phone: phone,
  engineerId: engineerId,
  isUrgent: isUrgent,
  images: images,
);
    result.when(
      success: (createdProblem) {
        print('تم إنشاء المشكلة بنجاح: ${createdProblem.problemAddress}');

        final newIssue = createdProblem;

        final updatedIssues = [newIssue, ...state.techSupportIssues];

        emit(state.copyWith(
          status: CustomerStatus.success,
          isProblemAdded: true,
          newlyAddedIssue: newIssue,
          newlyAddedIssueTime: DateTime.now(),
          techSupportIssues: updatedIssues,
        ));
      },
      failure: (error) {
        print('فشل إنشاء المشكلة: ${error.errMessages}');
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: error.errMessages ?? 'فشل في إضافة المشكلة',
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