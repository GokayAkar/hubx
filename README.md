# hubx

Flutter app: Bloc + auto_route + gen-l10n + Material 3 light/dark, feature'lar
api / impl / ui olarak ayrılmış.

## Komutlar

```bash
flutter pub get                     # bağımlılıklar
flutter gen-l10n                    # .arb -> lib/l10n/generated (pub get ile de çalışır)
dart run build_runner watch         # auto_route + json_serializable codegen
flutter run                         # uygulamayı çalıştır
flutter analyze && flutter test     # kontroller
dart run tool/check_layer_deps.dart # impl sızıntısı kontrolü (CI)
```

## Mimari

Her feature üç katmandan oluşur ve **sadece api katmanı dışarıya görünür**:

```
lib/features/<ad>/
  api/    contract'lar: repository interface'i, route path sabitleri, modeller
  impl/   <ad>_impl.dart  -> library; tek public üye register<Ad>Domain()
          src/*.dart      -> part dosyaları; sınıflar _ ile başlar
  ui/     <ad>_ui.dart    -> barrel; register<Ad>Ui() + dışa açılan widget'lar
          bloc/           -> bloc + event + state
          view/           -> page (DI + bloc) ve screen (saf widget)
```

Gizlilik konvansiyon değil, **derleyici garantisi**: `impl/src/` altındaki
dosyalar `part` olduğu için import bile edilemez (`import_of_non_library`),
sınıflar `_` ile başladığı için kütüphane dışından görünmez. Uygulamanın
gördüğü tek şey `register*` fonksiyonudur.

`register*` fonksiyonlarını çağıran tek yer composition root'tur:
[app_dependencies.dart](lib/app/di/app_dependencies.dart). Başka bir yerden
`impl/` importu `tool/check_layer_deps.dart` ile CI'da kırılır.

### Açılış

Açılışta okunan her şey tek yerde toplanır:
[app/startup/](lib/app/startup/). `AppStartup` iki parçadan oluşur —
`UserPreferences` (tema, dil) ve `UserStatus` (onboarding tamamlandı mı, ileride
auth vb.). [app_startup_loader.dart](lib/app/startup/app_startup_loader.dart)
bunları feature'ların **api**'lerinden **paralel** okur.

```dart
// main.dart
AppDependencies.register();
final startup = await AppStartupLoader.load();
runApp(App(startup: startup));
```

Böylece ilk frame hem doğru tema/dille çizilir (flash yok) hem de doğru ekranda
açılır. Yeni bir açılış bilgisi eklemek: contract'ı feature'ın api'sine koy,
loader'daki `.wait` kaydına bir satır ekle, `UserPreferences` veya `UserStatus`
içine alanı ekle.

**Onboarding kapısı** [app.dart](lib/app/view/app.dart) içindeki
`deepLinkBuilder`'dadır: onboarding bitmemişse her giriş noktası — soğuk açılış
da, gelen bir deep link de — onboarding'e gider; bittikten sonra platformdan
gelen link olduğu gibi işlenir. Yeni kapılar (auth, KYC) aynı yere eklenir.

DI'a erişim [DependencyProvider](lib/core/di/dependency_provider.dart)
üzerindendir; hiçbir feature `get_it`'i doğrudan görmez. Kayıt her zaman
interface tipiyle yapılır: `registerLazySingleton<SettingsRepository>`.

Bloc'lar iki gruba ayrılır:

- **Ekrana ait bloc'lar** DI'a `registerFactory` ile kaydedilir — her ekran
  açılışında yeni instance, `BlocProvider(create:)` sahiplenir ve kapatır
  (örnek: [home_ui.dart](lib/features/home/ui/home_ui.dart)).
- **App geneli bloc'lar** DI'a hiç girmez; widget tree'nin en tepesinde
  kurulur (örnek: [app.dart](lib/app/view/app.dart) içindeki `SettingsBloc`).
  Service locator'da singleton bloc tutmak lifecycle'ı kaybettirir, `close()`
  çağıran kimse olmaz.

### Feature'lar arası geçiş

Bir feature başka bir feature'ın widget'ını **görmez**; api'de yayınlanan path
sabitiyle gider:

```dart
context.router.pushPath(SettingsRoutes.root);
```

Path -> sayfa eşlemesi tek yerde,
[app_router.dart](lib/app/router/app_router.dart) içinde yapılır.

### Core

```
lib/app/
  di/       composition root
  startup/  AppStartup + AppStartupLoader (açılışta okunanlar)
  router/   path -> sayfa eşlemesi
  view/     App widget'ı

lib/core/
  di/       DependencyProvider (get_it facade)
  storage/  api/  KeyValueStorage + StorageKey<T> + KeyValueStorageFactory
            impl/ shared_preferences implementasyonu (private)
  theme/    light + dark ThemeData, tek seed color
  extensions/ context.l10n, context.colors, context.textTheme
```

Storage namespace'lidir: her feature `storageFor('<ad>')` ile kendi alanını
alır, key çakışması olmaz, `clear()` sadece o alanı siler. Anahtarlar
`StorageKey<T>` olduğu için okuma tipi derleme zamanında bellidir.

### Test

Private implementasyon testten doğrudan kurulamaz — testler contract üzerinden
yazılır: `register*` çağrılır, `DependencyProvider.get<X>()` ile alınır
(bkz. [settings_repository_test.dart](test/features/settings/impl/settings_repository_test.dart)).
Bloc testleri interface'i elle fake'ler, mock kütüphanesi gerekmez.

## Yeni şeyler eklerken

- **Yeni feature:** `api/` içine contract + route path, `impl/` içine library +
  part'lar + `register<Ad>Domain()`, `ui/` içine `bloc/` + `view/` +
  `register<Ad>Ui()`. Son adım: `AppDependencies` içine register çağrılarını,
  `AppRouter` içine route'u eklemek.
- **Yeni sayfa:** widget'a `@RoutePage()` ekle, `dart run build_runner build`
  çalıştır, path sabitini feature'ın api'sine, route'u `AppRouter`'a ekle.
- **Yeni metin:** `app_en.arb`'ye anahtar + `@anahtar` açıklamasını,
  `app_tr.arb`'ye karşılığını ekle; kullanım `context.l10n.anahtar`.
- **Yeni dil:** `lib/l10n/arb/app_<kod>.arb` oluştur — `supportedLocales`
  otomatik büyür.
- **Renk/tipografi:** tek yer, [app_theme.dart](lib/core/theme/app_theme.dart).
