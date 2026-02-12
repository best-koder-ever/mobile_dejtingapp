import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/models/wizard_models.dart';

void main() {
  // ──── WizardStepBasicInfoDto ────
  group('WizardStepBasicInfoDto', () {
    WizardStepBasicInfoDto makeDto({
      String firstName = 'Alice',
      String lastName = 'Smith',
      DateTime? dateOfBirth,
      String gender = 'Woman',
    }) {
      return WizardStepBasicInfoDto(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
        gender: gender,
      );
    }

    test('isValid returns true for valid 25-year-old', () {
      expect(makeDto().isValid(), isTrue);
    });

    test('isValid rejects empty firstName', () {
      expect(makeDto(firstName: '').isValid(), isFalse);
    });

    test('isValid rejects empty lastName', () {
      expect(makeDto(lastName: '').isValid(), isFalse);
    });

    test('isValid rejects empty gender', () {
      expect(makeDto(gender: '').isValid(), isFalse);
    });

    test('isValid rejects under-18', () {
      final dob = DateTime.now().subtract(const Duration(days: 365 * 16));
      expect(makeDto(dateOfBirth: dob).isValid(), isFalse);
    });

    test('isValid accepts exactly 18', () {
      final dob = DateTime.now().subtract(const Duration(days: 365 * 18 + 1));
      expect(makeDto(dateOfBirth: dob).isValid(), isTrue);
    });

    test('toJson includes all fields', () {
      final dto = makeDto();
      final json = dto.toJson();
      expect(json['firstName'], 'Alice');
      expect(json['lastName'], 'Smith');
      expect(json['gender'], 'Woman');
      expect(json.containsKey('dateOfBirth'), isTrue);
    });

    test('toJson dateOfBirth is ISO 8601', () {
      final dto = makeDto();
      final json = dto.toJson();
      expect(json['dateOfBirth'], isA<String>());
      expect(() => DateTime.parse(json['dateOfBirth'] as String), returnsNormally);
    });
  });

  // ──── WizardStepPreferencesDto ────
  group('WizardStepPreferencesDto', () {
    test('isValid with all nulls', () {
      final dto = WizardStepPreferencesDto();
      expect(dto.isValid(), isTrue);
    });

    test('isValid with valid age range', () {
      final dto = WizardStepPreferencesDto(minAge: 20, maxAge: 30);
      expect(dto.isValid(), isTrue);
    });

    test('isValid rejects minAge under 18', () {
      final dto = WizardStepPreferencesDto(minAge: 16, maxAge: 30);
      expect(dto.isValid(), isFalse);
    });

    test('isValid rejects maxAge under 18', () {
      final dto = WizardStepPreferencesDto(minAge: 18, maxAge: 17);
      expect(dto.isValid(), isFalse);
    });

    test('isValid rejects minAge > maxAge', () {
      final dto = WizardStepPreferencesDto(minAge: 35, maxAge: 25);
      expect(dto.isValid(), isFalse);
    });

    test('isValid accepts equal minAge and maxAge', () {
      final dto = WizardStepPreferencesDto(minAge: 25, maxAge: 25);
      expect(dto.isValid(), isTrue);
    });

    test('isValid rejects distance < 1', () {
      final dto = WizardStepPreferencesDto(maxDistance: 0);
      expect(dto.isValid(), isFalse);
    });

    test('isValid rejects distance > 300', () {
      final dto = WizardStepPreferencesDto(maxDistance: 301);
      expect(dto.isValid(), isFalse);
    });

    test('isValid accepts distance 1', () {
      final dto = WizardStepPreferencesDto(maxDistance: 1);
      expect(dto.isValid(), isTrue);
    });

    test('isValid accepts distance 300', () {
      final dto = WizardStepPreferencesDto(maxDistance: 300);
      expect(dto.isValid(), isTrue);
    });

    test('toJson omits null fields', () {
      final dto = WizardStepPreferencesDto();
      expect(dto.toJson(), isEmpty);
    });

    test('toJson omits empty bio', () {
      final dto = WizardStepPreferencesDto(bio: '');
      expect(dto.toJson().containsKey('bio'), isFalse);
    });

    test('toJson includes non-null fields', () {
      final dto = WizardStepPreferencesDto(
        preferredGender: 'Man',
        minAge: 21,
        maxAge: 35,
        maxDistance: 50,
        bio: 'Hello!',
      );
      final json = dto.toJson();
      expect(json['preferredGender'], 'Man');
      expect(json['minAge'], 21);
      expect(json['maxAge'], 35);
      expect(json['maxDistance'], 50);
      expect(json['bio'], 'Hello!');
    });
  });

  // ──── WizardStepPhotosDto ────
  group('WizardStepPhotosDto', () {
    test('isValid with one photo', () {
      final dto = WizardStepPhotosDto(photoUrls: ['http://example.com/a.jpg']);
      expect(dto.isValid(), isTrue);
    });

    test('isValid rejects empty list', () {
      final dto = WizardStepPhotosDto(photoUrls: []);
      expect(dto.isValid(), isFalse);
    });

    test('toJson includes photoUrls', () {
      final dto = WizardStepPhotosDto(photoUrls: ['url1', 'url2']);
      expect(dto.toJson()['photoUrls'], ['url1', 'url2']);
    });
  });

  // ──── WizardProgress ────
  group('WizardProgress', () {
    test('default starts at basicInfo', () {
      final p = WizardProgress();
      expect(p.currentStep, WizardStep.basicInfo);
      expect(p.step1Complete, isFalse);
      expect(p.step2Complete, isFalse);
      expect(p.step3Complete, isFalse);
    });

    test('canProceed false when step1 not complete at basicInfo', () {
      final p = WizardProgress();
      expect(p.canProceed, isFalse);
    });

    test('canProceed true when step1 is complete at basicInfo', () {
      final p = WizardProgress(step1Complete: true);
      expect(p.canProceed, isTrue);
    });

    test('canProceed at preferences requires step2', () {
      final p = WizardProgress(
        currentStep: WizardStep.preferences,
        step2Complete: true,
      );
      expect(p.canProceed, isTrue);
    });

    test('canProceed at photos requires step3', () {
      final p = WizardProgress(
        currentStep: WizardStep.photos,
        step3Complete: true,
      );
      expect(p.canProceed, isTrue);
    });

    test('canGoBack false at basicInfo', () {
      expect(WizardProgress().canGoBack, isFalse);
    });

    test('canGoBack true at preferences', () {
      final p = WizardProgress(currentStep: WizardStep.preferences);
      expect(p.canGoBack, isTrue);
    });

    test('canGoBack true at photos', () {
      final p = WizardProgress(currentStep: WizardStep.photos);
      expect(p.canGoBack, isTrue);
    });

    test('nextStep from basicInfo is preferences', () {
      expect(WizardProgress().nextStep, WizardStep.preferences);
    });

    test('nextStep from preferences is photos', () {
      final p = WizardProgress(currentStep: WizardStep.preferences);
      expect(p.nextStep, WizardStep.photos);
    });

    test('nextStep from photos is null', () {
      final p = WizardProgress(currentStep: WizardStep.photos);
      expect(p.nextStep, isNull);
    });

    test('previousStep from basicInfo is null', () {
      expect(WizardProgress().previousStep, isNull);
    });

    test('previousStep from preferences is basicInfo', () {
      final p = WizardProgress(currentStep: WizardStep.preferences);
      expect(p.previousStep, WizardStep.basicInfo);
    });

    test('previousStep from photos is preferences', () {
      final p = WizardProgress(currentStep: WizardStep.photos);
      expect(p.previousStep, WizardStep.preferences);
    });

    test('stepIndex 0 for basicInfo', () {
      expect(WizardProgress().stepIndex, 0);
    });

    test('stepIndex 1 for preferences', () {
      expect(WizardProgress(currentStep: WizardStep.preferences).stepIndex, 1);
    });

    test('stepIndex 2 for photos', () {
      expect(WizardProgress(currentStep: WizardStep.photos).stepIndex, 2);
    });

    test('progress is 1/3 for basicInfo', () {
      expect(WizardProgress().progress, closeTo(1 / 3, 0.01));
    });

    test('progress is 2/3 for preferences', () {
      expect(
        WizardProgress(currentStep: WizardStep.preferences).progress,
        closeTo(2 / 3, 0.01),
      );
    });

    test('progress is 1.0 for photos', () {
      expect(
        WizardProgress(currentStep: WizardStep.photos).progress,
        1.0,
      );
    });

    // ---- copyWith ----

    test('copyWith preserves all fields when no overrides', () {
      final p = WizardProgress(
        currentStep: WizardStep.preferences,
        step1Complete: true,
        step2Complete: true,
        step3Complete: false,
      );
      final copy = p.copyWith();
      expect(copy.currentStep, WizardStep.preferences);
      expect(copy.step1Complete, isTrue);
      expect(copy.step2Complete, isTrue);
      expect(copy.step3Complete, isFalse);
    });

    test('copyWith overrides currentStep', () {
      final p = WizardProgress();
      final copy = p.copyWith(currentStep: WizardStep.photos);
      expect(copy.currentStep, WizardStep.photos);
      expect(copy.step1Complete, isFalse); // preserved
    });

    test('copyWith overrides step flags', () {
      final p = WizardProgress();
      final copy = p.copyWith(step1Complete: true, step3Complete: true);
      expect(copy.step1Complete, isTrue);
      expect(copy.step2Complete, isFalse); // preserved
      expect(copy.step3Complete, isTrue);
    });
  });

  // ──── Enums ────
  group('Enums', () {
    test('OnboardingStatus has 3 values', () {
      expect(OnboardingStatus.values.length, 3);
    });

    test('WizardStep has 3 values', () {
      expect(WizardStep.values.length, 3);
    });

    test('WizardStep values are basicInfo, preferences, photos', () {
      expect(WizardStep.values, [
        WizardStep.basicInfo,
        WizardStep.preferences,
        WizardStep.photos,
      ]);
    });
  });
}
