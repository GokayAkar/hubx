import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Application name shown in the task switcher
  ///
  /// In en, this message translates to:
  /// **'HubX'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Text between ** is the emphasised half of the heading
  ///
  /// In en, this message translates to:
  /// **'Welcome to **PlantApp**'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Identify more than 3000+ plants and 88% accuracy.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingWelcomeAction.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingWelcomeAction;

  /// Opens the legal line; the two link labels follow it
  ///
  /// In en, this message translates to:
  /// **'By tapping next, you are agreeing to PlantID'**
  String get onboardingLegal;

  /// No description provided for @onboardingTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get onboardingTermsOfUse;

  /// No description provided for @onboardingPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get onboardingPrivacyPolicy;

  /// Joins the two link labels, spaces included
  ///
  /// In en, this message translates to:
  /// **' & '**
  String get onboardingLegalSeparator;

  /// Closes the legal line after the second link. Languages that inflect the object carry that ending here
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get onboardingLegalSuffix;

  /// No description provided for @onboardingScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo to **identify** the plant!'**
  String get onboardingScanTitle;

  /// No description provided for @onboardingCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Get plant **care guides**'**
  String get onboardingCareTitle;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// Text between ** is the emphasised half
  ///
  /// In en, this message translates to:
  /// **'**PlantApp** Premium'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access All Features'**
  String get paywallSubtitle;

  /// No description provided for @paywallFeatureUnlimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get paywallFeatureUnlimitedTitle;

  /// No description provided for @paywallFeatureUnlimitedBody.
  ///
  /// In en, this message translates to:
  /// **'Plant Identify'**
  String get paywallFeatureUnlimitedBody;

  /// No description provided for @paywallFeatureFasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get paywallFeatureFasterTitle;

  /// No description provided for @paywallFeatureFasterBody.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get paywallFeatureFasterBody;

  /// No description provided for @paywallPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get paywallPeriodMonth;

  /// No description provided for @paywallPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get paywallPeriodYear;

  /// No description provided for @paywallMonthlyDetail.
  ///
  /// In en, this message translates to:
  /// **'{price}/month, auto renewable'**
  String paywallMonthlyDetail(String price);

  /// No description provided for @paywallYearlyDetail.
  ///
  /// In en, this message translates to:
  /// **'First {days} days free, then {price}/year'**
  String paywallYearlyDetail(int days, String price);

  /// No description provided for @paywallSave.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String paywallSave(int percent);

  /// No description provided for @paywallTrialCta.
  ///
  /// In en, this message translates to:
  /// **'Try free for {days} days'**
  String paywallTrialCta(int days);

  /// No description provided for @paywallSubscribeCta.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get paywallSubscribeCta;

  /// No description provided for @paywallTrialTerms.
  ///
  /// In en, this message translates to:
  /// **'After the {days}-day free trial period you’ll be charged {price} per year unless you cancel before the trial expires. Yearly Subscription is Auto-Renewable'**
  String paywallTrialTerms(int days, String price);

  /// No description provided for @paywallRecurringTerms.
  ///
  /// In en, this message translates to:
  /// **'{price} per month, auto-renewable until you cancel.'**
  String paywallRecurringTerms(String price);

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get paywallTerms;

  /// No description provided for @paywallPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get paywallPrivacy;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get paywallRestore;

  /// No description provided for @paywallLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the plans'**
  String get paywallLoadFailedTitle;

  /// No description provided for @paywallLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get paywallLoadFailedBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @homeGreetingHi.
  ///
  /// In en, this message translates to:
  /// **'Hi, plant lover!'**
  String get homeGreetingHi;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning! ☀️'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon! ⛅'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening! 🌙'**
  String get homeGreetingEvening;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for plants'**
  String get homeSearchHint;

  /// No description provided for @homePremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'**FREE** Premium Available'**
  String get homePremiumTitle;

  /// No description provided for @homePremiumBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to upgrade your account!'**
  String get homePremiumBody;

  /// No description provided for @homeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get homeGetStarted;

  /// No description provided for @homeCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get homeCategoriesEmpty;

  /// No description provided for @homeLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load this'**
  String get homeLoadFailed;

  /// No description provided for @navDiagnose.
  ///
  /// In en, this message translates to:
  /// **'Diagnose'**
  String get navDiagnose;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan a plant'**
  String get navScan;

  /// No description provided for @navGarden.
  ///
  /// In en, this message translates to:
  /// **'My Garden'**
  String get navGarden;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystem;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
