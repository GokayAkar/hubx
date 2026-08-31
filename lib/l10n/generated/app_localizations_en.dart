// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HubX';

  @override
  String get homeTitle => 'Home';

  @override
  String get onboardingWelcomeTitle => 'Welcome to **PlantApp**';

  @override
  String get onboardingWelcomeBody =>
      'Identify more than 3000+ plants and 88% accuracy.';

  @override
  String get onboardingWelcomeAction => 'Get Started';

  @override
  String get onboardingLegal => 'By tapping next, you are agreeing to PlantID';

  @override
  String get onboardingTermsOfUse => 'Terms of Use';

  @override
  String get onboardingPrivacyPolicy => 'Privacy Policy';

  @override
  String get onboardingLegalSeparator => ' & ';

  @override
  String get onboardingLegalSuffix => '.';

  @override
  String get onboardingScanTitle => 'Take a photo to **identify** the plant!';

  @override
  String get onboardingCareTitle => 'Get plant **care guides**';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get paywallTitle => '**PlantApp** Premium';

  @override
  String get paywallSubtitle => 'Access All Features';

  @override
  String get paywallFeatureUnlimitedTitle => 'Unlimited';

  @override
  String get paywallFeatureUnlimitedBody => 'Plant Identify';

  @override
  String get paywallFeatureFasterTitle => 'Faster';

  @override
  String get paywallFeatureFasterBody => 'Process';

  @override
  String get paywallPeriodMonth => '1 Month';

  @override
  String get paywallPeriodYear => '1 Year';

  @override
  String paywallMonthlyDetail(String price) {
    return '$price/month, auto renewable';
  }

  @override
  String paywallYearlyDetail(int days, String price) {
    return 'First $days days free, then $price/year';
  }

  @override
  String paywallSave(int percent) {
    return 'Save $percent%';
  }

  @override
  String paywallTrialCta(int days) {
    return 'Try free for $days days';
  }

  @override
  String get paywallSubscribeCta => 'Subscribe';

  @override
  String paywallTrialTerms(int days, String price) {
    return 'After the $days-day free trial period you’ll be charged $price per year unless you cancel before the trial expires. Yearly Subscription is Auto-Renewable';
  }

  @override
  String paywallRecurringTerms(String price) {
    return '$price per month, auto-renewable until you cancel.';
  }

  @override
  String get paywallTerms => 'Terms';

  @override
  String get paywallPrivacy => 'Privacy';

  @override
  String get paywallRestore => 'Restore';

  @override
  String get paywallLoadFailedTitle => 'We couldn\'t load the plans';

  @override
  String get paywallLoadFailedBody => 'Check your connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get loading => 'Loading';

  @override
  String get homeGreetingHi => 'Hi, plant lover!';

  @override
  String get homeGreetingMorning => 'Good Morning! ☀️';

  @override
  String get homeGreetingAfternoon => 'Good Afternoon! ⛅';

  @override
  String get homeGreetingEvening => 'Good Evening! 🌙';

  @override
  String get homeSearchHint => 'Search for plants';

  @override
  String get homePremiumTitle => '**FREE** Premium Available';

  @override
  String get homePremiumBody => 'Tap to upgrade your account!';

  @override
  String get homeGetStarted => 'Get Started';

  @override
  String get homeCategoriesEmpty => 'No categories yet';

  @override
  String get homeLoadFailed => 'We couldn’t load this';

  @override
  String get navDiagnose => 'Diagnose';

  @override
  String get navScan => 'Scan a plant';

  @override
  String get navGarden => 'My Garden';

  @override
  String get navProfile => 'Profile';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageSystem => 'System language';
}
