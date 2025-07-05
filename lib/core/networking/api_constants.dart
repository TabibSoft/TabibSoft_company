class ApiConstants {
  static const String apiBaseUrl = 'http://tabibsoft.ddns.net:7260/api/';

  static const String login = 'Auth/Login';

  static const String getCurrentUser = 'Auth'; // إضافة نقطة نهائية جديدة

  static const String addCustomer = 'Customer/AddCustomer';

  static const String getAllCustomers = 'Customer/GetAllCustomer';

  static const String getTechnicalSupportData =
      'Problem/GetTechnicalSupportData/{Id}';

  static const String getAllTechSupport = 'Problem/GetAllTechSupport';

  static const String getAllProblemCategories = 'Problem/GetAllProblemCategory';

//   static const String getAllSitiuation = 'Problem/GetAllSitiuation'; // Fetch situation/filter data

  static const String getProblemStatus = 'Problem/GetProblemStatus';

  static const String changeProblemStatus = 'Problem/ChangeProblemStatus';

  static const String createUnderTransaction = 'Problem/CreateUnderTransaction';

  static const String getUnderTransaction =
      'Problem/GetUnderTransaction'; // إضافة جديدة

  static const String deleteUnderTransaction =
      'Problem/DeleteUnderTransaction/{Id}'; // إضافة جديدة

  static const String getAllEngineers = 'Problem/GetAllEng';

  static const String autoCompleteCustomer = 'Customer/AutoCompleteCustomer';

  static const String createProblem = 'Problem/CreateProblem';

  static const String getAllMeasurements = 'Sales/GetAllMeasurement';

  static const String getDealDetailById =
      'Sales/GetDealDetailById'; // إضافة جديدة

  static const String addRequirement = 'Sales/AddRequirement'; // إضافة جديدة

  static const String getAllOffers = 'Sales/GetAllOffers'; // إضافة جديدة

  static const String getAllProducts = 'Sales/GetAllProudcts';

  static const String getAllPaymentMethods =
      'Sales/GetAllPaymentMethod'; // إضافة جديدة

  static const String addPayment = 'Sales/AddPayment'; // إضافة جديدة

  static const String makeMeasurementDone =
      'Sales/MakeMeasurementDone'; // إضافة جديدة

  static const String getAllProgrammerTasks = 'Programer/GetAll'; 
  static const String getProgrammerTaskById = 'Programer/GetById';
}
