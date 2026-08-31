// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'HubX';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get onboardingWelcomeTitle => '**PlantApp**\'e hoş geldin';

  @override
  String get onboardingWelcomeBody =>
      '3000\'den fazla bitkiyi %88 doğrulukla tanı.';

  @override
  String get onboardingWelcomeAction => 'Başla';

  @override
  String get onboardingLegal => 'Devam ederek PlantID';

  @override
  String get onboardingTermsOfUse => 'Kullanım Koşulları';

  @override
  String get onboardingPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get onboardingLegalSeparator => ' ve ';

  @override
  String get onboardingLegalSuffix => '\'nı kabul etmiş olursun.';

  @override
  String get onboardingScanTitle => 'Bitkiyi **tanımak** için fotoğraf çek!';

  @override
  String get onboardingCareTitle => '**Bakım rehberlerine** ulaş';

  @override
  String get onboardingContinue => 'Devam';

  @override
  String get paywallTitle => '**PlantApp** Premium';

  @override
  String get paywallSubtitle => 'Tüm Özelliklere Eriş';

  @override
  String get paywallFeatureUnlimitedTitle => 'Sınırsız';

  @override
  String get paywallFeatureUnlimitedBody => 'Bitki Tanıma';

  @override
  String get paywallFeatureFasterTitle => 'Daha Hızlı';

  @override
  String get paywallFeatureFasterBody => 'İşlem';

  @override
  String get paywallPeriodMonth => '1 Ay';

  @override
  String get paywallPeriodYear => '1 Yıl';

  @override
  String paywallMonthlyDetail(String price) {
    return '$price/ay, otomatik yenilenir';
  }

  @override
  String paywallYearlyDetail(int days, String price) {
    return 'İlk $days gün ücretsiz, sonrası $price/yıl';
  }

  @override
  String paywallSave(int percent) {
    return '%$percent tasarruf';
  }

  @override
  String paywallTrialCta(int days) {
    return '$days gün ücretsiz dene';
  }

  @override
  String get paywallSubscribeCta => 'Abone ol';

  @override
  String paywallTrialTerms(int days, String price) {
    return '$days günlük deneme süresi bittiğinde, deneme dolmadan iptal etmezsen yıllık $price tahsil edilir. Yıllık abonelik otomatik yenilenir.';
  }

  @override
  String paywallRecurringTerms(String price) {
    return 'Aylık $price, sen iptal edene kadar otomatik yenilenir.';
  }

  @override
  String get paywallTerms => 'Koşullar';

  @override
  String get paywallPrivacy => 'Gizlilik';

  @override
  String get paywallRestore => 'Geri yükle';

  @override
  String get paywallLoadFailedTitle => 'Planları yükleyemedik';

  @override
  String get paywallLoadFailedBody => 'Bağlantını kontrol edip tekrar dene.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get loading => 'Yükleniyor';

  @override
  String get homeGreetingHi => 'Merhaba, bitki sever!';

  @override
  String get homeGreetingMorning => 'Günaydın! ☀️';

  @override
  String get homeGreetingAfternoon => 'İyi Günler! ⛅';

  @override
  String get homeGreetingEvening => 'İyi Akşamlar! 🌙';

  @override
  String get homeSearchHint => 'Bitki ara';

  @override
  String get homePremiumTitle => '**ÜCRETSİZ** Premium';

  @override
  String get homePremiumBody => 'Hesabını yükseltmek için dokun!';

  @override
  String get homeGetStarted => 'Başlayalım';

  @override
  String get homeCategoriesEmpty => 'Henüz kategori yok';

  @override
  String get homeLoadFailed => 'Bunu yükleyemedik';

  @override
  String get navDiagnose => 'Teşhis';

  @override
  String get navScan => 'Bitki tara';

  @override
  String get navGarden => 'Bahçem';

  @override
  String get navProfile => 'Profil';

  @override
  String get comingSoon => 'Çok yakında';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get languageSystem => 'Sistem dili';
}
