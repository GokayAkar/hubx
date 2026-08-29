import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/features/onboarding/api/onboarding_api.dart';
import 'package:hubx/features/onboarding/ui/steps/bloc/onboarding_bloc.dart';

export 'steps/bloc/onboarding_bloc.dart';
export 'steps/onboarding_steps_page.dart';
export 'welcome/onboarding_welcome_page.dart';

/// Registers this feature's presentation dependencies.
void registerOnboardingUi() {
  DependencyProvider.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(DependencyProvider.get<OnboardingRepository>()),
  );
}
