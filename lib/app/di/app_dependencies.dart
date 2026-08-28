import 'package:hubx/core/storage/impl/key_value_storage_impl.dart';
import 'package:hubx/features/home/ui/home_ui.dart';
import 'package:hubx/features/onboarding/impl/onboarding_impl.dart';
import 'package:hubx/features/onboarding/ui/onboarding_ui.dart';
import 'package:hubx/features/settings/impl/settings_impl.dart';

/// Composition root: the one place that knows implementations exist.
///
/// Every other file in the app only ever sees the contracts in `*/api/`.
/// Core infrastructure is registered before the features that depend on it.
///
/// App-wide blocs are deliberately absent here — they belong to the widget
/// tree, which owns and closes them. Only screen-scoped blocs are registered,
/// as factories.
abstract final class AppDependencies {
  static void register() {
    _registerCore();
    _registerFeatures();
  }

  static void _registerCore() {
    registerKeyValueStorage();
  }

  static void _registerFeatures() {
    registerSettingsDomain();
    registerOnboardingDomain();
    registerOnboardingUi();
    registerHomeUi();
  }
}
