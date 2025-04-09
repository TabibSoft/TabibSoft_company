class ApiConstants {
  static const String apiBaseUrl = 'http://tabibsoft.ddns.net:7260/api/';
  static const String login = 'Auth/Login';

  static const String addCustomer = 'Customer/AddCustomer';
  static const String getAllCustomers = 'Customer/GetAllCustomer';
  static const String getTechnicalSupportData = 'Problem/GetTechnicalSupportData/{Id}';
  static const String getAllTechSupport = 'Problem/GetAllTechSupport'; 
  static const String getProblemStatus = 'Problem/GetProblemStatus';
  static const String changeProblemStatus = 'Problem/ChangeProblemStatus';
}
