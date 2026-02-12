import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'DatingApp'**
  String get appTitle;

  /// Continue button label used throughout the app
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// Skip button label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginTitle;

  /// Registration screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// Auth required message
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get authRequired;

  /// Auth required detail message
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please log in again.'**
  String get authRequiredDetail;

  /// Apple sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Back to login link
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// Phone entry screen title
  ///
  /// In en, this message translates to:
  /// **'Can we get your number?'**
  String get onboardingPhoneTitle;

  /// Phone number input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get onboardingPhoneHint;

  /// SMS code verification screen title
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get onboardingVerifyCode;

  /// Verification in progress
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get onboardingVerifying;

  /// Code resent message with remaining count
  ///
  /// In en, this message translates to:
  /// **'Code resent ({remaining} left)'**
  String onboardingCodeResent(int remaining);

  /// Country selector title
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get onboardingSelectCountry;

  /// First name screen title
  ///
  /// In en, this message translates to:
  /// **'What\'s your first name?'**
  String get onboardingFirstNameTitle;

  /// Birthday screen title
  ///
  /// In en, this message translates to:
  /// **'When\'s your birthday?'**
  String get onboardingBirthdayTitle;

  /// Gender screen title
  ///
  /// In en, this message translates to:
  /// **'What\'s your gender?'**
  String get onboardingGenderTitle;

  /// Orientation screen title
  ///
  /// In en, this message translates to:
  /// **'What\'s your orientation?'**
  String get onboardingOrientationTitle;

  /// Relationship goals screen title
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get onboardingRelationshipGoalsTitle;

  /// Match preferences screen title
  ///
  /// In en, this message translates to:
  /// **'Match Preferences'**
  String get onboardingMatchPrefsTitle;

  /// Photos screen title
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get onboardingPhotosTitle;

  /// Lifestyle screen title
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get onboardingLifestyleTitle;

  /// Interests screen title
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get onboardingInterestsTitle;

  /// About me screen title
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get onboardingAboutMeTitle;

  /// Location permission screen title
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get onboardingLocationTitle;

  /// Location permission subtitle
  ///
  /// In en, this message translates to:
  /// **'We use your location to show you potential matches nearby'**
  String get onboardingLocationSubtitle;

  /// Enable location button text
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocationButton;

  /// Maybe later button text
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLaterButton;

  /// Notifications permission screen title
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get onboardingNotificationsTitle;

  /// Notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone likes you or sends a message'**
  String get onboardingNotificationsSubtitle;

  /// Enable notifications button
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotificationsButton;

  /// Onboarding complete screen title
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get onboardingCompleteTitle;

  /// Onboarding complete subtitle
  ///
  /// In en, this message translates to:
  /// **'Your profile is ready. Start discovering amazing people!'**
  String get onboardingCompleteSubtitle;

  /// Start discovering button text
  ///
  /// In en, this message translates to:
  /// **'Start Discovering'**
  String get startDiscoveringButton;

  /// Agree button for community guidelines
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get iAgreeButton;

  /// Age range slider label
  ///
  /// In en, this message translates to:
  /// **'Age Range: {min} - {max}'**
  String ageRangeLabel(int min, int max);

  /// Photo added placeholder text
  ///
  /// In en, this message translates to:
  /// **'Photo {index} added (placeholder)'**
  String photoAdded(int index);

  /// Delete photo confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get deletePhotoConfirmation;

  /// Interests limit hint
  ///
  /// In en, this message translates to:
  /// **'Add up to {max} interests to show on your profile.'**
  String addUpToInterests(int max);

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// Matches tab label
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchesTab;

  /// Messages tab label
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTab;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// Empty discovery message
  ///
  /// In en, this message translates to:
  /// **'Check back later for new people'**
  String get noNewPeople;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again'**
  String get connectionError;

  /// Connected status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Connecting status
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// Block user action
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// Report user action
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportUser;

  /// Add comment placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a comment?'**
  String get addComment;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About DatingApp'**
  String get aboutApp;

  /// Account settings section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// Privacy settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Control your privacy settings'**
  String get privacySettings;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Network unavailable error
  ///
  /// In en, this message translates to:
  /// **'Network unavailable. Please check your connection.'**
  String get errorNetworkUnavailable;

  /// Session expired error
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorSessionExpired;

  /// Required field validation error
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorFieldRequired;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
