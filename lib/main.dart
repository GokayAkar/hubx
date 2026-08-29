import 'package:flutter/material.dart';
import 'package:hubx/app/app.dart';
import 'package:hubx/app/di/app_dependencies.dart';
import 'package:hubx/app/startup/app_startup_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppDependencies.register();

  // Framework errors, uncaught async errors and bloc activity now reach the
  // logger too.
  AppDependencies.attachErrorHandlers();

  // Preferences and status are read here, so the first frame already uses the
  // right theme and language and lands on the right screen. A failure must
  // still produce a usable app rather than a blank window.
  final startup = await AppStartupLoader.loadOrFallback();

  runApp(App(startup: startup));
}
