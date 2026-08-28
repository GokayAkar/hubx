# hubx

Flutter app: Bloc + auto_route + gen-l10n + Material 3 light/dark, with every
feature split into api / impl / ui.

## Commands

```bash
flutter pub get                     # dependencies
flutter gen-l10n                    # .arb -> lib/l10n/generated (also runs on pub get)
dart run build_runner watch         # auto_route + json_serializable codegen
flutter run                         # run the app
flutter analyze && flutter test     # checks
dart run tool/check_layer_deps.dart # guard against impl leaking (CI)
```

## Architecture

Every feature has three layers, and **only the api layer is visible to the rest
of the app**:

```
lib/features/<name>/
  api/    contracts: repository interface, route path constants, models
  impl/   <name>_impl.dart -> library; register<Name>Domain() is its only
                              public member
          src/*.dart       -> part files; classes are prefixed with _
  ui/     <name>_ui.dart   -> barrel; register<Name>Ui() + exported widgets
          bloc/            -> bloc + event + state
          view/            -> page (DI + bloc) and screen (pure widget)
```

Privacy here is not a convention but a **compiler guarantee**: files under
`impl/src/` are `part` files, so they cannot even be imported
(`import_of_non_library`), and their classes start with `_`, so they are
invisible outside their own library. All the app can reach is the `register*`
function.

The composition root is the only caller of those functions:
[app_dependencies.dart](lib/app/di/app_dependencies.dart). An `impl/` import
from anywhere else fails `tool/check_layer_deps.dart` in CI.

### Startup

Everything read at launch is gathered in one place:
[app/startup/](lib/app/startup/). `AppStartup` has two halves —
`UserPreferences` (theme, locale) and `UserStatus` (onboarding done, later auth
and friends). [app_startup_loader.dart](lib/app/startup/app_startup_loader.dart)
reads them from the features' **api** contracts, **in parallel**.

```dart
// main.dart
AppDependencies.register();
final startup = await AppStartupLoader.load();
runApp(App(startup: startup));
```

So the first frame is painted in the right theme and language (no flash) and
lands on the right screen. To add a new piece of startup data: put the contract
in the feature's api, add one line to the loader's `.wait`, add the field to
`UserPreferences` or `UserStatus`.

**The entry point** is baked into the router at construction:
`AppRouter(startOnOnboarding: ...)` marks either home or onboarding as
`initial`. Which screen the app opens on is a launch-time decision, so it is
expressed once, declaratively, and never re-evaluated — nothing can go stale
and there is no redirect to keep correct.

That is an entry point, not a gate: it says where the app starts, not where the
user may go. Once real deep links exist, a link could reach a screen behind
onboarding — that is an `AutoRouteGuard`'s job, asking the repository on every
navigation instead of caching a flag in the app shell.

DI is reached through
[DependencyProvider](lib/core/di/dependency_provider.dart); no feature ever
sees `get_it`. Registration always uses the interface as the type argument:
`registerLazySingleton<SettingsRepository>`.

Blocs fall into two groups:

- **Screen-scoped blocs** are registered with `registerFactory` — a fresh
  instance per screen, owned and closed by `BlocProvider(create:)`
  (see [home_ui.dart](lib/features/home/ui/home_ui.dart)).
- **App-wide blocs** stay out of DI entirely and are created at the top of the
  widget tree (see `SettingsBloc` in [app.dart](lib/app/view/app.dart)).
  A singleton bloc in a service locator loses its lifecycle: nothing ever calls
  `close()`.

### Navigating between features

A feature never **sees** another feature's widgets; it navigates with the path
constant published in that feature's api:

```dart
context.router.pushPath(SettingsRoutes.root);
```

Path -> page mapping happens in one place,
[app_router.dart](lib/app/router/app_router.dart).

### Core

```
lib/app/
  di/       composition root
  startup/  AppStartup + AppStartupLoader (what is read at launch)
  router/   path -> page mapping
  view/     the App widget

lib/core/
  di/       DependencyProvider (get_it facade)
  logging/  api/  Logger + LogSink + LogSinkRegistry + LogEntry
            impl/ console sink, fan-out logger, bloc observer (private)
  storage/  api/  KeyValueStorage + StorageKey<T> + KeyValueStorageFactory
            impl/ shared_preferences implementation (private)
  theme/    light + dark ThemeData from a single seed color
  extensions/ context.l10n, context.colors, context.textTheme
```

### Logging

One contract, [Logger](lib/core/logging/api/logger.dart), fanning out to any
number of `LogSink`s. Calling code never knows where an entry ends up; sinks
look at the entry type and decide for themselves:

| Type | For | Example destination |
|---|---|---|
| `LogMessage` (debug/info/warning/error) | diagnostics and errors | console, Datadog, Crashlytics |
| `LogEvent` | user action / business event | Firebase Analytics |

```dart
// features/cards/api/cards_api.dart — each feature owns its source constant
abstract final class CardsLog {
  static const source = LogSource('cards');
}

final log = DependencyProvider.get<Logger>().withSource(CardsLog.source);
log.error('POST /cards failed', error: e, stackTrace: s, context: {'status': 500});
log.event('card_ordered', properties: {'type': 'virtual'});
```

`LogSource` is a typed constant rather than an enum: core owns the
infrastructure sources (`LogSource.app`, `.bloc`, `.flutter`, `.platform`) and
each feature declares its own, so adding a feature never means editing a list
inside core.

**Adding a backend** never touches the logging implementation — it writes a
private sink in its own module and registers it:

```dart
// core/logging/datadog/datadog_logging_impl.dart
void registerDatadogLogging(DatadogConfig config) {
  DependencyProvider.get<LogSinkRegistry>().addSink(_DatadogLogSink(config));
}
```

Then one line in `AppDependencies._registerCore()`. The console sink does not
even have to go: they all run side by side, and one failing sink never takes
the others down.

`attachLoggingHandlers()` in [main.dart](lib/main.dart) wires up the error
streams the app does not own: `FlutterError.onError` (UI errors),
`PlatformDispatcher.onError` (uncaught async errors) and `Bloc.observer` — so
every dispatched bloc event becomes a user-action record on its own, with no
log lines sprinkled through the screens.

### Storage

Storage is namespaced: each feature takes its own space with
`storageFor('<name>')`, keys cannot collide, and `clear()` wipes that space
only. Keys are `StorageKey<T>`, so the type of a read is fixed at compile time.

### Tests

A private implementation cannot be constructed from a test, so tests go through
the contract: call `register*`, resolve with `DependencyProvider.get<X>()`
(see [settings_repository_test.dart](test/features/settings/impl/settings_repository_test.dart)).
Bloc tests fake the interface by hand — no mocking library needed.

## Adding things

- **A feature:** contract + route path in `api/`, library + parts +
  `register<Name>Domain()` in `impl/`, `bloc/` + `view/` +
  `register<Name>Ui()` in `ui/`. Last step: the register calls in
  `AppDependencies` and the route in `AppRouter`.
- **A page:** annotate the widget with `@RoutePage()`, run
  `dart run build_runner build`, add the path constant to the feature's api and
  the route to `AppRouter`.
- **A string:** add the key plus its `@key` description to `app_en.arb` and the
  translation to `app_tr.arb`; use it as `context.l10n.key`.
- **A language:** create `lib/l10n/arb/app_<code>.arb` — `supportedLocales`
  grows on its own.
- **Colors / typography:** one place,
  [app_theme.dart](lib/core/theme/app_theme.dart).
