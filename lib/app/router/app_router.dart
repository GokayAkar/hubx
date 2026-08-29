import 'package:auto_route/auto_route.dart';
import 'package:hubx/app/router/app_router.gr.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';
import 'package:hubx/features/settings/api/settings_api.dart';

/// Maps the paths published by each feature's `api` to that feature's pages.
///
/// Features never reference each other's route classes — they navigate with
/// the path constants, e.g. `context.router.pushPath(SettingsRoutes.root)`.
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter({required this.startOnOnboarding});

  /// Decided once, at launch, from the startup snapshot.
  final bool startOnOnboarding;

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      path: HomeRoutes.root,
      initial: !startOnOnboarding,
    ),
    AutoRoute(
      page: OnboardingWelcomeRoute.page,
      path: OnboardingRoutes.root,
      initial: startOnOnboarding,
    ),
    AutoRoute(page: OnboardingStepsRoute.page, path: OnboardingRoutes.steps),
    AutoRoute(page: PaywallRoute.page, path: PaywallRoutes.root),
    AutoRoute(page: SettingsRoute.page, path: SettingsRoutes.root),
  ];
}
