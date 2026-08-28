import 'package:flutter_test/flutter_test.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/storage/impl/key_value_storage_impl.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:hubx/features/onboarding/impl/onboarding_impl.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late OnboardingRepository repository;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await DependencyProvider.reset();
    registerKeyValueStorage();
    registerOnboardingDomain();
    repository = DependencyProvider.get<OnboardingRepository>();
  });

  group('OnboardingRepository', () {
    test('is incomplete on a fresh install', () async {
      expect(await repository.isCompleted(), isFalse);
    });

    test('remembers that the flow was finished', () async {
      await repository.markCompleted();

      expect(await repository.isCompleted(), isTrue);
    });
  });
}
