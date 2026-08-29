import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/ui/app_icon_button.dart';
import 'package:hubx/features/home/ui/bloc/home_bloc.dart';
import 'package:hubx/features/settings/api/settings_api.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // A factory registration: every visit to this screen gets a fresh bloc,
      // and BlocProvider closes it when the screen goes away.
      create: (_) => DependencyProvider.get<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return _HomeScreen(
            count: state.count,
            onTap: () => context.read<HomeBloc>().add(const HomeTapped()),
            // Navigating by path keeps this feature free of the settings
            // widgets.
            onOpenSettings: () => context.router.pushPath(SettingsRoutes.root),
          );
        },
      ),
    );
  }
}

/// Pure presentation: no DI, no bloc — takes values, returns callbacks.
class _HomeScreen extends StatelessWidget {
  const _HomeScreen({
    required this.count,
    required this.onTap,
    required this.onOpenSettings,
  });

  final int count;
  final VoidCallback onTap;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.homeTitle),
        actions: [
          AppIconButton(
            icon: Icons.settings_outlined,
            label: context.l10n.settingsTitle,
            onPressed: onOpenSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.homeGreeting('Gokay'),
              style: context.textTheme.headlineSmall,
            ),
            SizedBox(height: AppSpacing.s8),
            Text(
              context.l10n.counterLabel(count),
              style: context.textTheme.bodyLarge,
            ),
            SizedBox(height: AppSpacing.s24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s32),
              child: FilledButton(
                onPressed: onTap,
                // The icon is the whole label, so it carries the one a screen
                // reader announces.
                child: Icon(
                  Icons.add,
                  semanticLabel: context.l10n.homeIncrement,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
