// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DatingApp';

  @override
  String get continueButton => 'Continue';

  @override
  String get nextButton => 'Next';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get doneButton => 'Done';

  @override
  String get skipButton => 'Skip';

  @override
  String get backButton => 'Back';

  @override
  String get retryButton => 'Retry';

  @override
  String get loginTitle => 'Log In';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get authRequired => 'Authentication required';

  @override
  String get authRequiredDetail =>
      'Authentication required. Please log in again.';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get onboardingPhoneTitle => 'Can we get your number?';

  @override
  String get onboardingPhoneHint => 'Enter your phone number';

  @override
  String get onboardingVerifyCode => 'Verify Code';

  @override
  String get onboardingVerifying => 'Verifying...';

  @override
  String onboardingCodeResent(int remaining) {
    return 'Code resent ($remaining left)';
  }

  @override
  String get onboardingSelectCountry => 'Select Country';

  @override
  String get onboardingFirstNameTitle => 'What\'s your first name?';

  @override
  String get onboardingBirthdayTitle => 'When\'s your birthday?';

  @override
  String get onboardingGenderTitle => 'What\'s your gender?';

  @override
  String get onboardingOrientationTitle => 'What\'s your orientation?';

  @override
  String get onboardingRelationshipGoalsTitle => 'What are you looking for?';

  @override
  String get onboardingMatchPrefsTitle => 'Match Preferences';

  @override
  String get onboardingPhotosTitle => 'Add Photos';

  @override
  String get onboardingLifestyleTitle => 'Lifestyle';

  @override
  String get onboardingInterestsTitle => 'Interests';

  @override
  String get onboardingAboutMeTitle => 'About me';

  @override
  String get onboardingLocationTitle => 'Enable Location';

  @override
  String get onboardingLocationSubtitle =>
      'We use your location to show you potential matches nearby';

  @override
  String get enableLocationButton => 'Enable Location';

  @override
  String get maybeLaterButton => 'Maybe Later';

  @override
  String get onboardingNotificationsTitle => 'Enable Notifications';

  @override
  String get onboardingNotificationsSubtitle =>
      'Get notified when someone likes you or sends a message';

  @override
  String get enableNotificationsButton => 'Enable Notifications';

  @override
  String get onboardingCompleteTitle => 'You\'re All Set!';

  @override
  String get onboardingCompleteSubtitle =>
      'Your profile is ready. Start discovering amazing people!';

  @override
  String get startDiscoveringButton => 'Start Discovering';

  @override
  String get iAgreeButton => 'I agree';

  @override
  String ageRangeLabel(int min, int max) {
    return 'Age Range: $min - $max';
  }

  @override
  String photoAdded(int index) {
    return 'Photo $index added (placeholder)';
  }

  @override
  String get deletePhotoConfirmation =>
      'Are you sure you want to delete this photo?';

  @override
  String addUpToInterests(int max) {
    return 'Add up to $max interests to show on your profile.';
  }

  @override
  String get profileTab => 'Profile';

  @override
  String get matchesTab => 'Matches';

  @override
  String get messagesTab => 'Messages';

  @override
  String get settingsTab => 'Settings';

  @override
  String get noNewPeople => 'Check back later for new people';

  @override
  String get connectionError => 'Check your connection and try again';

  @override
  String get connected => 'Connected';

  @override
  String get connecting => 'Connecting...';

  @override
  String get blockUser => 'Block User';

  @override
  String get reportUser => 'Report';

  @override
  String get addComment => 'Add a comment?';

  @override
  String get aboutApp => 'About DatingApp';

  @override
  String get accountSection => 'Account';

  @override
  String get privacySettings => 'Control your privacy settings';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetworkUnavailable =>
      'Network unavailable. Please check your connection.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String get errorFieldRequired => 'This field is required';
}
