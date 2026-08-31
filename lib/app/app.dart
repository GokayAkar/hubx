import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/app/router/app_router.dart';
import 'package:hubx/app/startup/app_startup.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
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
  late final AppRouter _appRouter = AppRouter(
    startOnOnboarding: !widget.startup.status.isOnboardingCompleted,
  );

  late final RouterConfig<UrlState> _routerConfig = _appRouter.config();

  /// Guarantees a minimum gap at the bottom of every screen.
  ///
  /// A phone with a home indicator already leaves room; one without — an SE,
  /// most Androids — leaves none, and content ends up on the edge. Raising the
  /// inset here rather than in each screen means every `SafeArea` in the app
  /// gets it, including the ones inside bottom sheets and snack bars, and no
  /// screen has to remember.
  Widget _withBottomBreathingRoom(BuildContext context, Widget? child) {
    final media = MediaQuery.of(context);
    final bottom = math.max(media.padding.bottom, AppSpacing.s24);

    // Only `padding`, which is what SafeArea and scroll views read. Not
    // `viewPadding`: that is a statement about what the system is covering,
    // and this minimum is a decision about how the design should breathe.
    // Leaving it truthful is what lets a bar pinned to the very bottom find
    // out how much of the edge really belongs to the system.
    return MediaQuery(
      data: media.copyWith(padding: media.padding.copyWith(bottom: bottom)),
      child: child ?? const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferences = widget.startup.preferences;

    return ScreenUtilInit(
      designSize: kDesignSize,
      minTextAdapt: true,
      builder: (context, _) => BlocProvider(
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
              builder: _withBottomBreathingRoom,
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
      ),
    );
  }
}
