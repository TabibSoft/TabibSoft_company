class ApiConstants {
  static const String apiBaseUrl = 'https://tabibsoft.ddns.net:7260/api/';

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
  static const String updateUnderTransaction = 'Problem/UpdateUnderTransaction';

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
  static const String addCustomization = 'Programer/AddCustomization';
  static const String getSituationStatus = 'Programer/GetSitiouationStatus';

  static const String makeReportDone = 'Programer/MakeReportDone';
  static const String updateTask = 'Programer/UpdateTask';

  static const String getNotifications =
      'Notification/GetNotifications'; // Added for notifications

  static const String getTodayCalls =
      'Sales/GetTodayCalls'; // Added new constant

  static const String changeStatus = 'Sales/UpdateMeasurementStatus';

  static const String getAllStatuses = 'Sales/GetAllStatus';

  static const String addSubscription = 'Sales/AddSubscription';

//زيارات وتسطيبات
  static const String getAllVisits = 'Problem/GetAllVisits';
  static const String addVisitDetail = 'Problem/AddVisitDetail';
  static const String editVisitDetail = 'Problem/EditVisitDetail';
  static const String makeVisitDone = 'Problem/MakeVisitDone';

  static const String addNote = 'Problem/AddNote';
  static const String deleteNote = 'Problem/DeleteNote';
  static const String makeNoteRead = 'Problem/MakeNoteRead';

  static const String isArchive = 'Problem/IsArchive';

  static const String getCities = 'Customer/GetCities';
  static const String getGovernments = 'Customer/GetGovernments';

  // WhatsApp API - Port 7261
  static const String whatsAppBaseUrl =
      'https://tabibsoft.ddns.net:7261/api/WhatsApp';
  static const String whatsAppInstances = '/instances';
  static const String whatsAppNewMessages = '/new-messages';
  static const String whatsAppSendMessage = '/send-message';
  static const String whatsAppBulkMessage = '/bulk-message';
  static const String whatsAppBulkJobs = '/bulk-messages';
  static const String whatsAppChatMessages = '/chat-messages';
  static const String whatsAppContacts = '/contacts';
  static const String whatsAppHealth = '/health';
}
//171b7d44-57d9-4eac-4e90-08de535c797c
//