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
          <screen>/        -> one folder per screen: its page (DI + bloc), its
                              view (pure widget) and its bloc/ if it has one
          shared/          -> only once two screens actually share something
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
  widget tree (see `SettingsBloc` in [app.dart](lib/app/app.dart)).
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
  app.dart  the App widget

lib/core/
  di/       DependencyProvider (get_it facade)
  logging/  api/  Logger + LogSink + LogSinkRegistry + LogEntry
            impl/ console sink, log distributor, bloc observer (private)
  network/  api/  ApiException + RemoteService
            impl/ Dio registration
  storage/  api/  KeyValueStorage + StorageKey<T> + KeyValueStorageFactory
            impl/ shared_preferences implementation (private)
  theme/    colours, typography, dimensions, and the ThemeData built from them
  ui/       the few widgets that exist to make a mistake hard to make
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

### Networking

Dio does the work, and stays inside
[RemoteService](lib/core/network/api/remote_service.dart) — a feature's service
never imports it. That is not to keep the option of swapping Dio; it is so
there is exactly one path a request can take, and no service can skip the error
translation by awaiting Dio itself.

Two things live in [core/network/api](lib/core/network/api/):

**A sealed `ApiException`**, so failures are reasoned about by what went wrong
rather than by `DioExceptionType`. (`Api…`, not `Http…`: `dart:io` already
exports an `HttpException`, and a file importing both would not compile.)

| Exception | Meaning |
|---|---|
| `ApiStatusException` | the server answered, not with success (`isUnauthorized`, `isClientError`, `isServerError`) |
| `ApiConnectionException` | the server could not be reached |
| `ApiTimeoutException` | one of the configured timeouts elapsed |
| `ApiCancelledException` | the app cancelled it — not a failure |
| `ApiParsingException` | the body arrived but did not fit the model |
| `ApiUnknownException` | unclassifiable, including a response with no status code |

**`RemoteService`**, which every feature's remote data source extends. It
offers `get` / `post` / `put` / `patch` / `delete`, each taking a path and a
`JsonParser<T>`; the error translation, reporting and parser wrapping happen
once, inside:

```dart
class _CardsService extends RemoteService {
  const _CardsService(super.dio, super.logger);

  Future<List<CardDto>> fetchCards() => get(
    '/cards',
    (json) => [for (final item in json! as List) CardDto.fromJson(item)],
  );

  Future<void> order(String type) =>
      post('/cards', (_) {}, body: {'type': type});
}
```

Dio features these verbs do not cover — cancellation, upload progress,
multipart — are added to `RemoteService` as they are needed, rather than by
reaching around it.

Two interceptors are installed, in this order:

1. **Tracing** — every attempt is logged at `debug`: method, path, status and
   duration. Request and response bodies only in debug builds, and sensitive
   headers (`authorization`, `cookie`, `x-api-key`, …) are always redacted;
   these entries are meant to reach a remote sink one day. `debug` is below the
   release threshold, so none of it costs anything in production.
2. **Retry** (`dio_smart_retry`) — 2 attempts, 200ms then 500ms, with our own
   evaluator rather than the package's. It retries **idempotent methods only**
   (`GET`/`HEAD`/`PUT`/`DELETE`/`OPTIONS`), because a timed-out POST may well
   have reached the server and replaying it would place a second order — the
   package's default would. And only on failures that plausibly pass:
   timeouts, connection errors, and 408/429/502/503/504. Not 500: a server that
   threw will throw again, and retrying doubles the load on something already
   struggling.

Anything added later runs after both:
`DependencyProvider.get<Dio>().interceptors.add(...)`.

**Failures are reported by `RemoteService`, not by an interceptor.** An
interceptor sees every failure — including the ones a later interceptor
recovers from — and never sees a parse failure at all, so it can neither log
the truth nor stay quiet about a request that ended up succeeding. Severity
follows what actually happened: 5xx, transport failures and a body that did not
fit the model are errors; a 4xx is a warning, because not-logged-in and
not-found are the app's normal life; a cancelled request is debug, because the
app asked for it. Services are constructed with a logger already tagged with
their feature's source, so a failure names the feature whose call failed.

**Prepared for auth.** A `QueuedInterceptor` attaches the token, and on a 401
refreshes it and replays the request. Queuing serialises concurrent failures,
but each still arrives holding its own 401 — so the interceptor compares the
token the request was sent with against the current one and refreshes only if
nobody already did. Both behaviours are covered in
[remote_service_test.dart](test/core/network/remote_service_test.dart).

### Dimensions

The design is drawn on a **360 x 800** frame, and every dimension in the app is
expressed in those units. `flutter_screenutil` scales them by the device's
width, so a value read off the design lands proportionally on any phone:

```dart
Padding(padding: EdgeInsets.all(AppSpacing.s16))   // 16 on a 360 phone,
                                                   // 19 on a 430 one
```

Use the tokens in [app_dimensions.dart](lib/core/theme/app_dimensions.dart)
rather than raw numbers — that scale is what keeps screens looking like one
app, and it is the same scale the design is drawn on:

| Group | Values | Scaled by |
|---|---|---|
| `AppSpacing` | `s4` `s8` `s12` `s16` `s24` `s32` `s48`, plus `page` (= 16) | width (`.w`) |
| `AppRadius` | `r8` `r12` `r16` `r24` | the smaller ratio (`.r`), so a circle stays a circle |
| `AppSize` | `icon20`, `icon24`, `controlHeight` (48) | `.r`, with 48 as a floor |

Tokens are named for the value on the design, so "24 gap" in a review becomes
`AppSpacing.s24` with nothing to look up — and because only the steps of the
scale exist, a stray 13 or 17 cannot be typed in. Where a number is really a
decision rather than a measurement, it gets a name instead: `AppSpacing.page`,
`AppSize.controlHeight`.

Two deliberate choices:

- **Vertical gaps scale by width too.** Scaling them by height instead would
  stretch a square into a rectangle and make the rhythm differ between a short
  and a tall phone.
- **`controlHeight` never drops below 48.** A finger does not shrink with the
  screen, so the minimum touch target is a floor rather than a proportion.

Widget tests render at the reference frame, so the scale is 1 and an overflow a
real phone would show fails the test.
[app_dimensions_test.dart](test/core/theme/app_dimensions_test.dart) covers the
scaling itself at 320, 360 and 430.

### Assets

One folder per feature, so a screen's images sit next to nothing else:

```
assets/images/
  home/search_background.webp   1080x525
  onboarding/welcome.webp       1080x1454
  onboarding/scan.webp          1080x1584
  onboarding/detail.webp        1080x1605
  onboarding/title_brush.webp    404x33
  paywall/background.webp       1080x1398
```

Flutter does not recurse into subfolders, so each one gets its own line under
`assets:` in `pubspec.yaml`. `flutter_gen` mirrors the structure —
`Assets.images.onboarding.welcome` — and a wrong name stops compiling instead
of throwing on the device. Run `dart run build_runner build` after adding a
file.

**One file per image, not 1x/2x/3x variants.** Every variant ships in the app
bundle even though a device uses one, so three of them cost *more* download
than a single file at the largest size. The cost is memory: a 1080-wide image
decodes to the same bitmap on every phone, so pass `cacheWidth` where an image
is shown small.

Size each file as **display width in points x 3** — not "3x of the Figma
frame". A full-width image on the largest phone needs about 1080 physical
pixels; something shown at 100 pt needs 300, and shipping 1080 for it is
waste.

**WebP.** Flutter decodes it natively on both platforms, alpha included.

Pick the quality by measuring rather than by habit: `cwebp -print_psnr` reports
the distortion, and **42 dB is the usual visually-lossless threshold**. Sweep
downwards and take the lowest setting that still clears it — the answer differs
per image, from q85 for the onboarding photographs to q80 for the paywall
background, which is 7x smaller than lossless at 46 dB. Lossless is worth it
only for flat artwork with hard edges.

```bash
cwebp -q 85 -alpha_q 100 -exact -crop <x> <y> <w> <h> in.png -o out.webp
cwebp -q 85 in.png -o /dev/null -print_psnr   # check before committing
```

Crop in `cwebp`, not `sips` — `sips --cropOffset` exits 0 and silently does
nothing.

**Crop the transparent margin, measured at `alpha > 16`.** Figma leaves a
shadow tail whose alpha is non-zero but invisible; trimming at `alpha > 0`
keeps up to a hundred rows of nothing.

Give every image that carries meaning a `semanticLabel`, and every decorative
one `excludeFromSemantics: true` — otherwise a screen reader either says
nothing useful or repeats what the text beside it already said.

### Onboarding

One folder per screen — `ui/welcome/` and `ui/steps/` — rather than one folder
per kind. Grouping by kind (`view/`, `widgets/`, `bloc/`) puts a screen's parts
in three places and hides which of them belong together; grouping by screen
means everything a screen needs is in one folder, and deleting the screen
deletes the folder. There is no `shared/`: nothing is shared yet, and a folder
for that can be made the day something is.

Two routes. `/onboarding` is the welcome screen — no indicator, its own call to
action, and passed through once. `/onboarding/steps` holds the two illustrated
pages in a `PageView`.

They are separate because the button and the indicator have to hold still while
the pages slide: inside the `PageView` they travelled with the page. Only the
heading and the picture are in the pages; everything below sits in the screen
around them.

The indicator shows three dots for a flow of three screens, so on the steps it
starts at the second — `AnimatedSmoothIndicator` with `activeIndex: page + 1`
rather than the controller-driven variant, which assumes dot and page indices
match.

Finishing the last page marks onboarding done and replaces the route with
`/paywall`. Marked *before* the handover, so quitting on the paywall does not
send the user back through the flow.

The hand-drawn stroke under the emphasised words is placed from a
**measurement**, not from padding:
[EmphasisedText](lib/core/ui/emphasised_text.dart) lays the sentence out with a
`TextPainter` and asks `getBoxesForSelection` where the emphasised run actually
landed, then stretches the brush to each box. That is what makes it survive a
longer translation, a larger system text size, and a phrase that wrapped onto a
second line — the cases where a fixed-width underline drifts off the words.

### Typography

The design has 25 text styles; Material's `TextTheme` has 15 slots, and seven
of the design's styles are 16px differing only in line height. There is no
honest mapping, so [app_text_styles.dart](lib/core/theme/app_text_styles.dart)
is the source of truth and `AppTheme` builds a `TextTheme` from the handful
Material's own widgets read.

Tokens are named for what the designer says — weight and size — with the line
height appended only where two would collide:

```dart
AppTextStyles.extraBold28      // 28 / 800 / 100% / -1
AppTextStyles.semiBold16Lh24   // 16 / 600 / 24
AppTextStyles.semiBold16Lh21   // 16 / 600 / 21
AppTextStyles.underlined(AppTextStyles.regular11Lh15)
```

Line heights are stored as the design's pixel value divided by the font size,
because Flutter's `height` is a multiple — that ratio is what survives scaling.
Roboto is bundled at five weights (300/400/500/600/800); the 600 and 800 are
not in the Flutter SDK and were fetched from Google Fonts, and bundling rather
than downloading keeps iOS, where Roboto is not a system font, identical to
Android.

### Safe areas

Every screen is guaranteed a gap at the bottom, whether or not the device gives
one. A phone with a home indicator already leaves room; an SE or most Androids
leave none, and content lands on the edge.

The rule is applied once, in `MaterialApp.builder` in
[app.dart](lib/app/app.dart), by raising `MediaQuery.padding.bottom` to at
least `AppSpacing.s24`. Screens then use a plain `SafeArea()` and get it for
free — as do bottom sheets and snack bars, which read the same inset. No screen
has to remember, and there is nothing to repeat.

### Accessibility

[accessibility_test.dart](test/app/accessibility_test.dart) runs Flutter's own
guidelines over every screen, so a regression fails the build rather than
reaching a user. **The screen list is the router's** — a screen has to be
registered there to be reachable at all, so a new one cannot quietly skip these
checks:

| Guideline | What it protects |
|---|---|
| `androidTapTargetGuideline` / `iOSTapTargetGuideline` | targets big enough to hit — 48dp and 44pt |
| `labeledTapTargetGuideline` | every tappable says what it does out loud |
| `textContrastGuideline` | text stands out enough from what is behind it |

Plus each screen is rendered at `TextScaler.linear(2)` and must not overflow —
that is the setting most likely to break a layout in the real world.

Two habits keep it passing:

- Use [AppIconButton](lib/core/ui/app_icon_button.dart) for icon-only buttons:
  its `label` is required, so the accessible version is the default rather than
  the diligent one. Where an icon is the whole label of some other control,
  `Icon(Icons.add, semanticLabel: …)` does the same job.
- Never give a control a fixed `height`. `AppSize.controlHeight` is a
  *minimum*, so a button grows when the text does.

The wrapper is the convenience; the test is the guarantee. Nothing stops
someone reaching for a bare `IconButton`, and that is fine — the route-driven
test fails when its label is missing.

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
