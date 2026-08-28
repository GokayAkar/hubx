import 'package:flutter/material.dart';
import 'package:hubx/app/di/app_dependencies.dart';
import 'package:hubx/app/startup/app_startup_loader.dart';
import 'package:hubx/app/view/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppDependencies.register();

  // Preferences and status are read here, so the first frame already uses the
  // right theme and language and lands on the right screen.
  final startup = await AppStartupLoader.load();

  runApp(App(startup: startup));
}
