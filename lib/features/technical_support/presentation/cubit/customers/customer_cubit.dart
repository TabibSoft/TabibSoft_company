import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/add_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/repo/customer/customer_repo.dart';
import 'package:tabib_soft_company/features/technical_support/presentation/cubit/customers/customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _customerRepository;

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

  Future<void> addCustomer(CustomerModel customer) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.addCustomer(customer);
    result.when(
      success: (response) {
        emit(state.copyWith(
          status: CustomerStatus.success,
          customers: [...state.customers, customer],
        ));
      },
      failure: (error) => emit(state.copyWith(
        status: CustomerStatus.failure,
        errorMessage: error.errMessages,
      )),
    );
  }

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
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    print('Fetching tech support issues');
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.getAllTechSupport(
      customerId: customerId,
      date: date,
      address: address,
      problem: problem,
      isSearch: isSearch,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    result.when(
      success: (issues) {
        print('fetchTechSupportIssues succeeded: ${issues.length} issues');
        emit(state.copyWith(
          status: CustomerStatus.success,
          techSupportIssues: issues,
        ));
      },
      failure: (error) {
        print('fetchTechSupportIssues failed: ${error.errMessages}');
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

  Future<void> updateProblemStatus({
    required String customerSupportId,
    required String note,
    String? engineerId,
    required int problemStatusId,
    String? problemTitle,
    bool? solvid,
    required String customerId,
  }) async {
    print(
        'Starting updateProblemStatus: customerSupportId=$customerSupportId, note=$note, engineerId=$engineerId');
    emit(state.copyWith(status: CustomerStatus.loading));
    final result = await _customerRepository.changeProblemStatus(
      customerSupportId: customerSupportId,
      note: note,
      engineerId: engineerId,
      problemStatusId: problemStatusId,
      problemTitle: problemTitle,
      solvid: solvid,
      customerId: customerId,
    );
    result.when(
      success: (_) {
        print('updateProblemStatus succeeded');
        emit(state.copyWith(status: CustomerStatus.success));
        fetchTechSupportIssues(); // إعادة جلب البيانات
      },
      failure: (error) {
        print('updateProblemStatus failed: ${error.errMessages}');
        String errorMessage = error.errMessages;
        if (error.details != null) {
          final errors = error.details!['errors'] as Map<String, dynamic>?;
          if (errors != null) {
            errorMessage = errors.entries
                .map((e) => '${e.key}: ${e.value.join(', ')}')
                .join('\n');
          }
        }
        emit(state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: errorMessage,
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
      emit(state.copyWith(status: CustomerStatus.success, isProblemAdded: true));
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
}