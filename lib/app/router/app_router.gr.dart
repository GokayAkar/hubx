// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;
import 'package:hubx/app/shell/coming_soon_page.dart' as _i2;
import 'package:hubx/app/shell/main_shell_page.dart' as _i4;
import 'package:hubx/features/home/ui/detail/content_detail_page.dart' as _i1;
import 'package:hubx/features/home/ui/view/home_page.dart' as _i3;
import 'package:hubx/features/onboarding/ui/steps/onboarding_steps_page.dart'
    as _i5;
import 'package:hubx/features/onboarding/ui/welcome/onboarding_welcome_page.dart'
    as _i6;
import 'package:hubx/features/paywall/ui/paywall_page.dart' as _i7;
import 'package:hubx/features/settings/ui/view/settings_page.dart' as _i8;

/// generated route for
/// [_i1.ContentDetailPage]
class ContentDetailRoute extends _i9.PageRouteInfo<ContentDetailRouteArgs> {
  ContentDetailRoute({
    required String title,
    required String imageUrl,
    required String heroTag,
    String? subtitle,
    _i10.Key? key,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         ContentDetailRoute.name,
         args: ContentDetailRouteArgs(
           title: title,
           imageUrl: imageUrl,
           heroTag: heroTag,
           subtitle: subtitle,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'ContentDetailRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContentDetailRouteArgs>();
      return _i1.ContentDetailPage(
        title: args.title,
        imageUrl: args.imageUrl,
        heroTag: args.heroTag,
        subtitle: args.subtitle,
        key: args.key,
      );
    },
  );
}

class ContentDetailRouteArgs {
  const ContentDetailRouteArgs({
    required this.title,
    required this.imageUrl,
    required this.heroTag,
    this.subtitle,
    this.key,
  });

  final String title;

  final String imageUrl;

  final String heroTag;

  final String? subtitle;

  final _i10.Key? key;

  @override
  String toString() {
    return 'ContentDetailRouteArgs{title: $title, imageUrl: $imageUrl, heroTag: $heroTag, subtitle: $subtitle, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ContentDetailRouteArgs) return false;
    return title == other.title &&
        imageUrl == other.imageUrl &&
        heroTag == other.heroTag &&
        subtitle == other.subtitle &&
        key == other.key;
  }

  @override
  int get hashCode =>
      title.hashCode ^
      imageUrl.hashCode ^
      heroTag.hashCode ^
      subtitle.hashCode ^
      key.hashCode;
}

/// generated route for
/// [_i2.DiagnosePage]
class DiagnoseRoute extends _i9.PageRouteInfo<void> {
  const DiagnoseRoute({List<_i9.PageRouteInfo>? children})
    : super(DiagnoseRoute.name, initialChildren: children);

  static const String name = 'DiagnoseRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.DiagnosePage();
    },
  );
}

/// generated route for
/// [_i2.GardenPage]
class GardenRoute extends _i9.PageRouteInfo<void> {
  const GardenRoute({List<_i9.PageRouteInfo>? children})
    : super(GardenRoute.name, initialChildren: children);

  static const String name = 'GardenRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.GardenPage();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i9.PageRouteInfo<void> {
  const HomeRoute({List<_i9.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.MainShellPage]
class MainShellRoute extends _i9.PageRouteInfo<void> {
  const MainShellRoute({List<_i9.PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i4.MainShellPage();
    },
  );
}

/// generated route for
/// [_i5.OnboardingStepsPage]
class OnboardingStepsRoute extends _i9.PageRouteInfo<void> {
  const OnboardingStepsRoute({List<_i9.PageRouteInfo>? children})
    : super(OnboardingStepsRoute.name, initialChildren: children);

  static const String name = 'OnboardingStepsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.OnboardingStepsPage();
    },
  );
}

/// generated route for
/// [_i6.OnboardingWelcomePage]
class OnboardingWelcomeRoute extends _i9.PageRouteInfo<void> {
  const OnboardingWelcomeRoute({List<_i9.PageRouteInfo>? children})
    : super(OnboardingWelcomeRoute.name, initialChildren: children);

  static const String name = 'OnboardingWelcomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i6.OnboardingWelcomePage();
    },
  );
}

/// generated route for
/// [_i7.PaywallPage]
class PaywallRoute extends _i9.PageRouteInfo<void> {
  const PaywallRoute({List<_i9.PageRouteInfo>? children})
    : super(PaywallRoute.name, initialChildren: children);

  static const String name = 'PaywallRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i7.PaywallPage();
    },
  );
}

/// generated route for
/// [_i8.SettingsPage]
class SettingsRoute extends _i9.PageRouteInfo<void> {
  const SettingsRoute({List<_i9.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i8.SettingsPage();
    },
  );
}
