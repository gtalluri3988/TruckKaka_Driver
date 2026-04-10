import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/driver_app.dart';
import 'app/app_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await AppInit.initialize();

  runApp(const DriverApp());
}
