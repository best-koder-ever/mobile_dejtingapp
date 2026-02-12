// Wizard step DTOs matching UserService/DTOs/WizardStep*.cs

enum OnboardingStatus { incomplete, ready, suspended }

enum WizardStep { basicInfo, preferences, photos }

class WizardStepBasicInfoDto {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;

  WizardStepBasicInfoDto({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
  });

  bool isValid() {
    // Must be 18+
    final age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        gender.isNotEmpty &&
        age >= 18;
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
      };
}

class WizardStepPreferencesDto {
  final String? preferredGender;
  final int? minAge;
  final int? maxAge;
  final int? maxDistance;
  final String? bio;

  WizardStepPreferencesDto({
    this.preferredGender,
    this.minAge,
    this.maxAge,
    this.maxDistance,
    this.bio,
  });

  bool isValid() {
    // Age range validation
    if (minAge != null && maxAge != null) {
      if (minAge! < 18 || maxAge! < 18 || minAge! > maxAge!) {
        return false;
      }
    }
    // Distance validation
    if (maxDistance != null && (maxDistance! < 1 || maxDistance! > 300)) {
      return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (preferredGender != null) json['preferredGender'] = preferredGender;
    if (minAge != null) json['minAge'] = minAge;
    if (maxAge != null) json['maxAge'] = maxAge;
    if (maxDistance != null) json['maxDistance'] = maxDistance;
    if (bio != null && bio!.isNotEmpty) json['bio'] = bio;
    return json;
  }
}

class WizardStepPhotosDto {
  final List<String> photoUrls;

  WizardStepPhotosDto({required this.photoUrls});

  bool isValid() => photoUrls.isNotEmpty; // At least 1 photo required

  Map<String, dynamic> toJson() => {'photoUrls': photoUrls};
}

class WizardProgress {
  final WizardStep currentStep;
  final bool step1Complete;
  final bool step2Complete;
  final bool step3Complete;

  WizardProgress({
    this.currentStep = WizardStep.basicInfo,
    this.step1Complete = false,
    this.step2Complete = false,
    this.step3Complete = false,
  });

  WizardProgress copyWith({
    WizardStep? currentStep,
    bool? step1Complete,
    bool? step2Complete,
    bool? step3Complete,
  }) {
    return WizardProgress(
      currentStep: currentStep ?? this.currentStep,
      step1Complete: step1Complete ?? this.step1Complete,
      step2Complete: step2Complete ?? this.step2Complete,
      step3Complete: step3Complete ?? this.step3Complete,
    );
  }

  bool get canProceed {
    switch (currentStep) {
      case WizardStep.basicInfo:
        return step1Complete;
      case WizardStep.preferences:
        return step2Complete;
      case WizardStep.photos:
        return step3Complete;
    }
  }

  bool get canGoBack => currentStep != WizardStep.basicInfo;

  WizardStep? get nextStep {
    switch (currentStep) {
      case WizardStep.basicInfo:
        return WizardStep.preferences;
      case WizardStep.preferences:
        return WizardStep.photos;
      case WizardStep.photos:
        return null; // Last step
    }
  }

  WizardStep? get previousStep {
    switch (currentStep) {
      case WizardStep.basicInfo:
        return null; // First step
      case WizardStep.preferences:
        return WizardStep.basicInfo;
      case WizardStep.photos:
        return WizardStep.preferences;
    }
  }

  int get stepIndex {
    switch (currentStep) {
      case WizardStep.basicInfo:
        return 0;
      case WizardStep.preferences:
        return 1;
      case WizardStep.photos:
        return 2;
    }
  }

  double get progress => (stepIndex + 1) / 3;
}
