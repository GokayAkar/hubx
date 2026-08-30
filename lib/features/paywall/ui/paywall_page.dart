import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/core/theme/app_theme.dart';
import 'package:hubx/core/ui/app_icon_button.dart';
import 'package:hubx/core/ui/emphasised_text.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';
import 'package:hubx/features/paywall/ui/bloc/paywall_bloc.dart';
import 'package:hubx/features/paywall/ui/widgets/paywall_feature_cards.dart';
import 'package:hubx/features/paywall/ui/widgets/paywall_plan_tile.dart';
import 'package:hubx/gen/assets.gen.dart';
import 'package:skeletonizer/skeletonizer.dart';

@RoutePage()
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The paywall is drawn on a photograph and is dark whatever the rest of
    // the app is doing, so it takes the dark palette rather than the theme's.
    return Theme(
      data: AppTheme.dark,
      child: BlocProvider(
        create: (_) =>
            DependencyProvider.get<PaywallBloc>()..add(const PaywallStarted()),
        child: BlocBuilder<PaywallBloc, PaywallState>(
          builder: (context, state) => _PaywallScreen(
            state: state,
            onSelect: (id) =>
                context.read<PaywallBloc>().add(PaywallProductSelected(id)),
            // The same event the screen opens with: a retry is the first load
            // happening again, and giving it its own event would mean two
            // handlers to keep in step.
            onRetry: () =>
                context.read<PaywallBloc>().add(const PaywallStarted()),
            onClose: () =>
                unawaited(context.router.replacePath(HomeRoutes.root)),
          ),
        ),
      ),
    );
  }
}

/// Pure presentation: no DI, no bloc — takes values, returns callbacks.
class _PaywallScreen extends StatelessWidget {
  const _PaywallScreen({
    required this.state,
    required this.onSelect,
    required this.onRetry,
    required this.onClose,
  });

  final PaywallState state;
  final ValueChanged<String> onSelect;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            const _Backdrop(),
            // Switched on the status rather than on `isLoading`, so adding a
            // status is a compile error here instead of a blank screen.
            switch (state.status) {
              PaywallStatus.failed => _Failed(onRetry: onRetry),
              PaywallStatus.initial ||
              PaywallStatus.loading ||
              PaywallStatus.ready => _Content(onSelect: onSelect, state: state),
            },
            // The SafeArea above keeps its top open so the photograph runs
            // under the status bar. The button cannot: it is the one thing up
            // there a finger has to find, so it takes the inset itself.
            Positioned(
              top: MediaQuery.paddingOf(context).top + AppSpacing.s16,
              right: 0,
              child: _Close(onClose: onClose),
            ),
          ],
        ),
      ),
    );
  }
}

/// The photograph behind the top of the screen, fading into the page.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    final surface = context.palette.surface;

    return Positioned.fill(
      bottom: null,
      child: ShaderMask(
        // The image has no soft edge of its own; the mask gives it one so it
        // dissolves into the page instead of stopping on a line.
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [surface, surface.withValues(alpha: 0)],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: Assets.images.paywall.background.image(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

class _Close extends StatelessWidget {
  const _Close({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s8),
        child: AppIconButton(
          icon: Icons.close,
          label: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: onClose,
          background: context.palette.surface.withValues(alpha: 0.8),
          foreground: context.palette.textPrimary,
          size: 32.w,
        ),
      ),
    );
  }
}

class _Plans extends StatelessWidget {
  const _Plans({required this.state, required this.onSelect});

  final PaywallState state;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final loading = state.isLoading;
    final source = loading ? _placeholder : state;

    final plans = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final product in source.products) ...[
          _Plan(
            product: product,
            isSelected: product.id == source.selectedId,
            onSelected: () => onSelect(product.id),
          ),
          SizedBox(height: AppSpacing.s12),
        ],
        SizedBox(height: AppSpacing.s4),
        _Cta(product: source.selected),
        SizedBox(height: AppSpacing.s8),
        _SmallPrint(product: source.selected),
      ],
    );

    if (!loading) return plans;

    return Semantics(
      label: context.l10n.loading,
      container: true,
      child: ExcludeSemantics(
        child: Skeletonizer(
          // A shimmer sweeps; "reduce motion" is on for people whom movement
          // makes ill, so for them the bones simply sit there.
          effect: MediaQuery.disableAnimationsOf(context)
              ? SolidColorEffect(color: context.palette.surfaceRaised)
              : ShimmerEffect(
                  baseColor: context.palette.surfaceRaised,
                  highlightColor: context.palette.divider,
                ),
          child: plans,
        ),
      ),
    );
  }
}

/// Enough of a state to lay the plans out with: two of them, because that is
/// what the design has, and the one carrying a trial selected, because that is
/// the one the page opens on — and its terms run to two lines.
const _placeholder = PaywallState(
  status: PaywallStatus.ready,
  selectedId: 'yearly',
  products: [
    Product(
      id: 'monthly',
      period: SubscriptionPeriod.month,
      initialPrice: Price(amount: 2.99, currencyCode: 'USD'),
      renewalPrice: Price(amount: 2.99, currencyCode: 'USD'),
    ),
    Product(
      id: 'yearly',
      period: SubscriptionPeriod.year,
      freeTrial: Duration(days: 3),
      initialPrice: Price(amount: 274.99, currencyCode: 'USD'),
      renewalPrice: Price(amount: 529.99, currencyCode: 'USD'),
    ),
  ],
);

/// Shown when the plans could not be fetched.
///
/// The network layer has already retried what is worth retrying on its own, so
/// by the time this appears the failure has outlasted the automatic attempts
/// and only the user can decide to try again.
class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s24),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(
              Icons.cloud_off_rounded,
              size: AppSize.icon24 * 2,
              color: palette.textSecondary,
            ),
            SizedBox(height: AppSpacing.s16),
            Text(
              context.l10n.paywallLoadFailedTitle,
              style: AppTextStyles.medium20.copyWith(
                color: palette.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s8),
            Text(
              context.l10n.paywallLoadFailedBody,
              style: AppTextStyles.regular13.copyWith(
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s24),
            FilledButton(
              onPressed: onRetry,
              child: Text(context.l10n.retry),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// Everything below the photograph, from the title to the small print.
class _Content extends StatelessWidget {
  const _Content({required this.state, required this.onSelect});

  final PaywallState state;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    // The minimum height is what puts the page on the bottom: with room to
    // spare the column is taller than its children and `end` drops them to the
    // floor, leaving the photograph on show above. Without the scroll view
    // around it there is nowhere for the overflow to go, and at the system's
    // largest text the button and the terms fall off the screen entirely.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Title(),
              SizedBox(height: AppSpacing.s24),
              _Features(),
              SizedBox(height: AppSpacing.s24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Plans(state: state, onSelect: onSelect),
                    SizedBox(height: AppSpacing.s8),
                    const _Links(),
                  ],
                ),
              ),
              // Nothing below the links: the design has them against the
              // bottom, and the app's minimum inset is the only gap left.
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmphasisedText(
            context.l10n.paywallTitle,
            style: AppTextStyles.light28.copyWith(color: palette.textPrimary),
            emphasisStyle: AppTextStyles.extraBold28.copyWith(
              color: palette.textPrimary,
            ),
          ),
          Text(
            context.l10n.paywallSubtitle,
            style: AppTextStyles.light17.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Features extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // The third card has no design of its own; it repeats the first so the row
    // is long enough to show that it scrolls.
    final features = [
      PaywallFeature(
        icon: Assets.icons.identify,
        title: context.l10n.paywallFeatureUnlimitedTitle,
        body: context.l10n.paywallFeatureUnlimitedBody,
      ),
      PaywallFeature(
        icon: Assets.icons.speedometer,
        title: context.l10n.paywallFeatureFasterTitle,
        body: context.l10n.paywallFeatureFasterBody,
      ),
      PaywallFeature(
        icon: Assets.icons.identify,
        title: context.l10n.paywallFeatureUnlimitedTitle,
        body: context.l10n.paywallFeatureUnlimitedBody,
      ),
    ];

    return PaywallFeatureCards(features: features);
  }
}

class _Plan extends StatelessWidget {
  const _Plan({
    required this.product,
    required this.isSelected,
    required this.onSelected,
  });

  final Product product;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final saving = product.savingPercent;

    return PaywallPlanTile(
      title: switch (product.period) {
        SubscriptionPeriod.month => l10n.paywallPeriodMonth,
        SubscriptionPeriod.year => l10n.paywallPeriodYear,
      },
      // The line under the title is the ongoing cost; the small print at the
      // foot of the screen carries the first charge.
      detail: product.hasFreeTrial
          ? l10n.paywallYearlyDetail(
              product.freeTrial!.inDays,
              product.renewalPrice.format(locale),
            )
          : l10n.paywallMonthlyDetail(product.initialPrice.format(locale)),
      badge: saving == null ? null : l10n.paywallSave(saving),
      isSelected: isSelected,
      onSelected: onSelected,
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.product});

  final Product? product;

  @override
  Widget build(BuildContext context) {
    final trial = product?.freeTrial;

    return FilledButton(
      onPressed: product == null ? null : () {},
      // A trial is a property of the plan, not of the screen: offering "free
      // for 3 days" while the monthly plan is selected would be a lie.
      child: Text(
        trial == null
            ? context.l10n.paywallSubscribeCta
            : context.l10n.paywallTrialCta(trial.inDays),
      ),
    );
  }
}

class _SmallPrint extends StatelessWidget {
  const _SmallPrint({required this.product});

  final Product? product;

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();

    final locale = Localizations.localeOf(context).toString();
    final trial = product!.freeTrial;

    final terms = trial == null
        ? context.l10n.paywallRecurringTerms(
            product!.initialPrice.format(locale),
          )
        : context.l10n.paywallTrialTerms(
            trial.inDays,
            product!.initialPrice.format(locale),
          );

    // The monthly terms fit one line and the yearly ones take two, so picking
    // a plan changes this box's height — and because the page is anchored to
    // the bottom, that height is what everything above it stands on. Left
    // alone it snaps, and the whole page appears to twitch. Animating the box
    // turns the twitch into a slide: the same movement, slow enough to read as
    // the page making room rather than as a glitch.
    return AnimatedSize(
      duration: Durations.short4,
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: Durations.short4,
        child: Text(
          terms,
          // Keyed by the text: without this the switcher sees one Text that
          // happens to say something new, and crossfades nothing.
          key: ValueKey(terms),
          style: AppTextStyles.light9.copyWith(
            color: context.palette.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Links extends StatelessWidget {
  const _Links();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.regular11.copyWith(
      color: context.palette.textSecondary,
    );

    final labels = [
      context.l10n.paywallTerms,
      context.l10n.paywallPrivacy,
      context.l10n.paywallRestore,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (index, label) in labels.indexed) ...[
          if (index > 0) ExcludeSemantics(child: Text('\u00b7', style: style)),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(label, style: style),
          ),
        ],
      ],
    );
  }
}
