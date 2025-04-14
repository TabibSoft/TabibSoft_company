import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_model.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_req.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/add_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/add_customer_response.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/tech_support_response.dart'; // إضافة الاستيراد
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/create_under_transaction.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'api_constants.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiConstants.apiBaseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST(ApiConstants.login)
  Future<LoginModel> login(@Body() LoginRequest request);

  @POST(ApiConstants.addCustomer)
  Future<AddCustomerResponse> addCustomer(@Body() CustomerModel customer);

  @GET(ApiConstants.getAllCustomers)
  Future<List<CustomerModel>> getAllCustomers();

  @GET(ApiConstants.getTechnicalSupportData)
  Future<ProblemModel> getTechnicalSupportData(@Path("Id") int customerId);

  @GET(ApiConstants.getAllTechSupport)
  Future<TechSupportResponse> getAllTechSupport({
    @Query("customerId") String? customerId,
    @Query("date") String? date,
    @Query("address") String? address,
    @Query("problem") int? problem,
    @Query("isSearch") bool? isSearch,
    @Query("pageNumber") int pageNumber = 1,
    @Query("pageSize") int pageSize = 20,
  });

  @GET(ApiConstants.getProblemStatus)
  Future<List<ProblemStatusModel>> getProblemStatus();
//   @GET(ApiConstants.getUnderTransaction)
// Future<List<UnderTransactionModel>> getUnderTransaction({
//   @Query("CustomerSupportId") required String customerSupportId,
// });

  @POST(ApiConstants.changeProblemStatus)
  Future<void> changeProblemStatus({
    @Query("CustomerSupportId") required String customerSupportId,
    @Query("Note") String? note,
    @Query("EnginnerId") String? engineerId,
    @Query("ProblemstausId") required int problemStatusId,
    @Query("Problemtitle") String? problemTitle,
    @Query("Solvid") bool? solvid,
    @Query("CustomerId") required String customerId,
  });

  @POST(ApiConstants.createUnderTransaction)
Future<void> createUnderTransaction(@Body() CreateUnderTransaction dto);

  @GET(ApiConstants.getAllEngineers)
  Future<List<EngineerModel>> getAllEngineers();

  @GET(ApiConstants.autoCompleteCustomer)
  Future<List<CustomerModel>> autoCompleteCustomer(
      @Query("query") String query);

  @POST(ApiConstants.createProblem)
  Future<void> createProblem(@Body() FormData formData);
}
