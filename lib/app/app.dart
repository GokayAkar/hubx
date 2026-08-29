import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hubx/app/router/app_router.dart';
import 'package:hubx/app/startup/app_startup.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_theme.dart';
import 'package:hubx/features/settings/api/settings_api.dart';
import 'package:hubx/features/settings/ui/settings_ui.dart';
import 'package:hubx/l10n/generated/app_localizations.dart';

class App extends StatefulWidget {
  const App({required this.startup, super.key});

  /// Preferences and status read from disk before `runApp`.
  final AppStartup startup;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// Created once, from the startup snapshot: which screen the app opens on is
  /// a launch-time decision, so it is baked into the router instead of being
  /// re-evaluated on every incoming link.
  late final AppRouter _appRouter = AppRouter(
    startOnOnboarding: !widget.startup.status.isOnboardingCompleted,
  );

  /// Built once: a new config on every rebuild would cancel an in-flight route
  /// parse, silently dropping a deep link that arrives during a theme change.
  late final RouterConfig<UrlState> _routerConfig = _appRouter.config();

  @override
  Widget build(BuildContext context) {
    final preferences = widget.startup.preferences;

    return BlocProvider(
      // App-wide state lives at the root of the tree rather than in the
      // service locator, so its lifecycle is the app's own.
      create: (_) => SettingsBloc(
        DependencyProvider.get<SettingsRepository>(),
        initialState: SettingsState(
          themeMode: preferences.themeMode,
          locale: preferences.locale,
        ),
      ),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: _routerConfig,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.themeMode,
            locale: state.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (context) => context.l10n.appTitle,
          );
        },
      ),
    );
  }

}
