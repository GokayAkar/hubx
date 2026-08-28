import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:hubx/features/onboarding/ui/bloc/onboarding_bloc.dart';

export 'bloc/onboarding_bloc.dart';
export 'view/onboarding_page.dart';

/// Registers this feature's presentation dependencies.
void registerOnboardingUi() {
  DependencyProvider.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(DependencyProvider.get<OnboardingRepository>()),
  );
}
