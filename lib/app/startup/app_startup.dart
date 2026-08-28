import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Everything the app must know before it can paint its first frame.
///
/// Assembled by `AppStartupLoader` from the feature contracts, so no widget has
/// to wait on storage during the launch.
class AppStartup extends Equatable {
  const AppStartup({required this.preferences, required this.status});

  /// Choices the user made about how the app looks and speaks.
  final UserPreferences preferences;

  /// Where the user stands in the app's flows.
  final UserStatus status;

  /// What the app opens with when its stored state could not be read.
  static const fallback = AppStartup(
    preferences: UserPreferences(),
    status: UserStatus(),
  );

  @override
  List<Object?> get props => [preferences, status];
}

/// User preferences that shape the very first frame.
class UserPreferences extends Equatable {
  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.locale,
  });

  final ThemeMode themeMode;

  /// `null` follows the system language.
  final Locale? locale;

  @override
  List<Object?> get props => [themeMode, locale];
}

/// User status flags that decide where the app opens.
///
/// New gates (authentication, a pending KYC step, …) belong here next to
/// [isOnboardingCompleted].
class UserStatus extends Equatable {
  const UserStatus({this.isOnboardingCompleted = false});

  final bool isOnboardingCompleted;

  @override
  List<Object?> get props => [isOnboardingCompleted];
}
