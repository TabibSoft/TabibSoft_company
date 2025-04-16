class ApiConstants {
  static const String apiBaseUrl = 'http://tabibsoft.ddns.net:7260/api/';
  static const String login = 'Auth/Login';

  static const String addCustomer = 'Customer/AddCustomer';
  static const String getAllCustomers = 'Customer/GetAllCustomer';
  static const String getTechnicalSupportData =
      'Problem/GetTechnicalSupportData/{Id}';
  static const String getAllTechSupport = 'Problem/GetAllTechSupport';
  static const String getProblemStatus = 'Problem/GetProblemStatus';

  static const String changeProblemStatus = 'Problem/ChangeProblemStatus';
  static const String createUnderTransaction = 'Problem/CreateUnderTransaction';

  static const String getAllEngineers = 'Problem/GetAllEng';

  static const String autoCompleteCustomer = 'Customer/AutoCompleteCustomer';

  static const String createProblem = 'Problem/CreateProblem';

  static const String getAllMeasurements = 'Sales/GetAllMeasurement';
}
