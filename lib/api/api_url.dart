class ApiUrl {
  // 🔧 DEV: Use local machine IP for physical device testing.
  //        Change to production URL before release.
  static String baseUrl = 'http://192.168.29.198:5032/api/';
  // static String baseUrl = 'https://www.asva.co.in/TransportApi/api/';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static String register = 'Register/RegisterUser';
  static String checkDriverAccess = 'Auth/CheckDriverAccess';
  static String verifyOtp = 'Auth/VerifyOtp';
  static String loadMenus = 'Auth/LoadMenus';
  static String saveFcm = 'Auth/SaveFCM';

  // ── User ──────────────────────────────────────────────────────────────────
  static String getUserDetailsById = 'User/GetUserDetailsById';
  static String getUserByMobile = 'User/GetUserDetailsByMobile';
  static String updateLanguage = 'Register/UpdateUserLanguage';

  // ── Trip ──────────────────────────────────────────────────────────────────
  static String getAllTrips = 'Trip/GetAllTrips';
  static String getTripDetailsById = 'Trip/GetTripsDetailesById';
  static String updateTripStatus = 'Trip/UpdateTripStatusByDriver';
  static String getActiveAssignedTrip = 'Trip/GetActiveAssignedTrip';
  static String driverResponse = 'Trip/DriverResponse';
  static String confirmPickup = 'Trip/ConfirmPickup';
  static String saveTripImages = 'Trip/SaveTripImages';
  static String getTrackingLink = 'Trip/GetTrackingLink';

  // ── Advance & Salary ──────────────────────────────────────────────────────
  static String saveAdvanceRequest = 'Trip/SaveAdvanceRequest';
  static String getTripAdvanceByTripId = 'Trip/gettripAdvanceDetailsByTripId';
  static String getTripTransactions = 'Trip/GetAllTripTransactionHistory';
  static String getCurrentSalaryStatus = 'Trip/GetCurrentStatusForSalary';

  // ── Trip Documents ────────────────────────────────────────────────────────
  static String uploadTripDocument = 'Trip/UploadTripDocument';
  static String getTripDocuments   = 'Trip/GetTripDocuments';

  // ── Trip Expenses ─────────────────────────────────────────────────────────
  static String createTripExpense = 'TripTransaction/CreateTripTransaction';
  static String getTripExpenses   = 'TripTransaction/GetExpensesDetailsByTripId';

  // ── Notifications ─────────────────────────────────────────────────────────
  static String getUserNotifications = 'Notification/GetUserNotifications';
  static String markNotificationRead = 'Notification/MarkAsRead';
  static String markAllNotificationsRead = 'Notification/MarkAllRead';
}
