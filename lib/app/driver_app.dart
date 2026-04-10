import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import '../routes/app_routes.dart';
import '../utils/localization/app_translation.dart';

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TruckKaka Driver',
        translationsKeys: AppTranslation.translationsKeys,
        locale: const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: AppRoute.splash,
        getPages: AppRoute.pages,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B2A49),
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        unknownRoute: GetPage(
          name: '/404',
          page: () => Scaffold(
            appBar: AppBar(title: const Text('404')),
            body: const Center(child: Text('Page Not Found')),
          ),
        ),
      ),
    );
  }
}
