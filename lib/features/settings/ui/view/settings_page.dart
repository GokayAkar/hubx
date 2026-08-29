import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/features/settings/ui/bloc/settings_bloc.dart';
import 'package:hubx/l10n/generated/app_localizations.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<SettingsBloc>();

    return _SettingsScreen(
      themeMode: bloc.state.themeMode,
      locale: bloc.state.locale,
      onThemeModeChanged: (mode) => bloc.add(SettingsThemeModeChanged(mode)),
      onLocaleChanged: (locale) => bloc.add(SettingsLocaleChanged(locale)),
    );
  }
}

/// Pure presentation: no DI, no bloc — takes values, returns callbacks.
class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen({
    required this.themeMode,
    required this.locale,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(context.l10n.settingsAppearance),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (value) {
              if (value == null) return;
              onThemeModeChanged(value);
            },
            child: Column(
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: mode,
                    title: Text(_themeModeLabel(context.l10n, mode)),
                  ),
              ],
            ),
          ),
          Divider(height: AppSpacing.s32),
          _SectionHeader(context.l10n.settingsLanguage),
          RadioGroup<Locale?>(
            groupValue: locale,
            onChanged: onLocaleChanged,
            child: Column(
              children: [
                RadioListTile<Locale?>(
                  value: null,
                  title: Text(context.l10n.languageSystem),
                ),
                for (final supported in AppLocalizations.supportedLocales)
                  RadioListTile<Locale?>(
                    value: supported,
                    title: Text(_languageLabel(supported)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };
  }

  /// Language names stay in their own language, so they are not localized.
  String _languageLabel(Locale locale) {
    return switch (locale.languageCode) {
      'tr' => 'Türkçe',
      'en' => 'English',
      _ => locale.languageCode.toUpperCase(),
    };
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s8,
      ),
      child: Text(
        title,
        style: context.textTheme.labelLarge?.copyWith(
          color: context.colors.primary,
        ),
      ),
    );
  }
}
