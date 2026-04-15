import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/splash/splash_screen.dart';
import '../modules/login/login_screen.dart';
import '../modules/login/login_controller.dart';
import '../modules/otp/otp_screen.dart';
import '../modules/otp/otp_controller.dart';
import '../modules/language/language_screen.dart';
import '../modules/language/language_controller.dart';
import '../modules/main_screen/main_screen.dart';
import '../modules/main_screen/main_controller.dart';
import '../modules/home/home_controller.dart';
import '../modules/account/account_controller.dart';
import '../modules/payments/payments_controller.dart';
import '../modules/trips/assigned_trips/assigned_trips_screen.dart';
import '../modules/trips/assigned_trips/assigned_trips_controller.dart';
import '../modules/trips/trip_history/trip_history_screen.dart';
import '../modules/trips/trip_history/trip_history_controller.dart';
import '../modules/trips/trip_history/trip_history_detail_screen.dart';
import '../modules/trips/trip_history/trip_history_detail_controller.dart';
import '../modules/trips/trip_detail/trip_detail_screen.dart';
import '../modules/trips/trip_detail/trip_detail_controller.dart';
import '../modules/trips/active_trip/active_trip_screen.dart';
import '../modules/trips/active_trip/active_trip_controller.dart';
import '../modules/advance/advance_screen.dart';
import '../modules/advance/advance_controller.dart';
import '../modules/salary/salary_screen.dart';
import '../modules/salary/salary_controller.dart';

class AppRoute {
  // ── Route constants ────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String language = '/language';
  static const String dashboard = '/dashboard';
  static const String assignedTrips = '/assigned-trips';
  static const String tripHistory = '/trip-history';
  static const String tripHistoryDetail = '/trip-history-detail';
  static const String tripDetail = '/trip-detail';
  static const String activeTrip = '/active-trip';
  static const String advance = '/advance';
  static const String salary = '/salary';
  static const String unknown = '/404';

  // ── Pages ──────────────────────────────────────────────────────────────────
  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
      }),
    ),
    GetPage(
      name: otp,
      page: () => const OtpScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OtpController>(() => OtpController(), fenix: true);
      }),
    ),
    GetPage(
      name: language,
      page: () => const LanguageScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
      }),
    ),
    GetPage(
      name: dashboard,
      page: () => const MainScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MainController>(() => MainController(), fenix: true);
        Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
        Get.lazyPut<AccountController>(() => AccountController(), fenix: true);
        Get.lazyPut<PaymentsController>(() => PaymentsController(), fenix: true);
      }),
    ),
    GetPage(
      name: assignedTrips,
      page: () => const AssignedTripsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AssignedTripsController>(() => AssignedTripsController(), fenix: true);
      }),
    ),
    GetPage(
      name: tripHistory,
      page: () => const TripHistoryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TripHistoryController>(() => TripHistoryController(), fenix: true);
      }),
    ),
    GetPage(
      name: tripHistoryDetail,
      page: () => const TripHistoryDetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TripHistoryDetailController>(
            () => TripHistoryDetailController(), fenix: true);
      }),
    ),
    GetPage(
      name: tripDetail,
      page: () => const TripDetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TripDetailController>(() => TripDetailController(), fenix: true);
      }),
    ),
    GetPage(
      name: activeTrip,
      page: () => const ActiveTripScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ActiveTripController>(() => ActiveTripController(), fenix: true);
      }),
    ),
    GetPage(
      name: advance,
      page: () => const AdvanceScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdvanceController>(() => AdvanceController(), fenix: true);
      }),
    ),
    GetPage(
      name: salary,
      page: () => const SalaryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SalaryController>(() => SalaryController(), fenix: true);
      }),
    ),
    GetPage(
      name: unknown,
      page: () => Scaffold(
        appBar: AppBar(title: const Text('404')),
        body: const Center(child: Text('Page not found')),
      ),
    ),
  ];
}
