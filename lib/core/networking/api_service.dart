import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_response.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_request.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/engineer_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/task_details_model.dart';
import 'package:tabib_soft_company/features/sales/data/model/details/payment_method_model.dart';
import 'package:tabib_soft_company/features/sales/data/model/details/sales_details_model.dart';
import 'package:tabib_soft_company/features/sales/data/model/measurement_done/measurement_done_model.dart';
import 'package:tabib_soft_company/features/sales/data/model/paginated_sales_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/add_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/product_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/support_customer_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/problem_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/problem/tech_support_response.dart'; // إضافة الاستيراد
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/create_under_transaction.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_category_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/problem_status/problem_status_model.dart';
import 'api_constants.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiConstants.apiBaseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST(ApiConstants.login)
  Future<LoginResponse> login(
    @Body() LoginRequest request,
  );

  @POST(ApiConstants.addCustomer)
  Future addCustomer(@Body() AddCustomerModel customer);

  @GET(ApiConstants.getAllProducts)
  Future<List<ProductModel>> getAllProducts();

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

  @GET(ApiConstants.getAllProblemCategories)
  Future<List<ProblemCategoryModel>> getAllProblemCategories();

// @GET(ApiConstants.getAllSitiuation)
//   Future<List<ProblemStatusModel>> getAllSitiuation();

  @POST(ApiConstants.changeProblemStatus)
  Future<void> changeProblemStatus({
    @Query("CustomerSupportId") required String customerSupportId,
    @Query("Note") String? note,
    @Query("EnginnerId") String? engineerId,
    @Query("ProblemstausId") required String problemStatusId,
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

  @GET(ApiConstants.getAllMeasurements)
  Future<PaginatedSales> getAllMeasurements({
    @Query("page") int page = 1,
    @Query("pageSize") int pageSize = 10,
    @Query("statusId") String? statusId,
  });

  @GET(ApiConstants.getDealDetailById)
  Future<SalesDetailModel> getDealDetailById({
    @Query("id") required String id,
  });
  @GET(ApiConstants.getAllPaymentMethods)
  Future<List<PaymentMethodModel>> getAllPaymentMethods();
  @POST(ApiConstants.addPayment)
  Future<void> addPayment({
    @Query("PaymentDate") String? PaymentDate,
    @Query("PaymentNote") String? PaymentNote,
    @Query("Value") double? Value,
    @Query("MeasurementId") String? MeasurementId,
    @Query("payMethodId") String? payMethodId,
  });

  @POST(ApiConstants.addRequirement)
  Future<void> addRequirement(
    @Body() Map<String, dynamic> data,
    @Part() List<MultipartFile>? imageFiles,
  );

  @POST(ApiConstants.makeMeasurementDone)
  Future<void> makeMeasurementDone(@Body() Map<String, dynamic> body);

  @GET(ApiConstants.getAllProgrammerTasks)
  Future<List<CustomizationTaskModel>> getAllProgrammerTasks();

 @GET("Programer/GetById")
  Future<TaskDetailsModel> getProgrammerTaskById(@Query("id") String id);}
