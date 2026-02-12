import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/services/onboarding_coordinator.dart';

void main() {
  group('OnboardingCoordinator', () {
    test('has 16 total steps', () {
      expect(OnboardingCoordinator.totalSteps, 16);
    });

    test('steps list has 16 entries', () {
      expect(OnboardingCoordinator.steps.length, 16);
    });

    test('first step is /onboarding/phone', () {
      expect(OnboardingCoordinator.steps.first, '/onboarding/phone');
    });

    test('last step is /onboarding/complete', () {
      expect(OnboardingCoordinator.steps.last, '/onboarding/complete');
    });

    // ---- getNextRoute ----

    test('getNextRoute returns verify-code after phone', () {
      expect(
        OnboardingCoordinator.getNextRoute('/onboarding/phone'),
        '/onboarding/verify-code',
      );
    });

    test('getNextRoute returns null for last step', () {
      expect(
        OnboardingCoordinator.getNextRoute('/onboarding/complete'),
        isNull,
      );
    });

    test('getNextRoute returns null for unknown route', () {
      expect(
        OnboardingCoordinator.getNextRoute('/unknown'),
        isNull,
      );
    });

    test('getNextRoute from photos is location', () {
      expect(
        OnboardingCoordinator.getNextRoute('/onboarding/photos'),
        '/onboarding/location',
      );
    });

    // ---- getPreviousRoute ----

    test('getPreviousRoute returns phone before verify-code', () {
      expect(
        OnboardingCoordinator.getPreviousRoute('/onboarding/verify-code'),
        '/onboarding/phone',
      );
    });

    test('getPreviousRoute returns null for first step', () {
      expect(
        OnboardingCoordinator.getPreviousRoute('/onboarding/phone'),
        isNull,
      );
    });

    test('getPreviousRoute returns null for unknown route', () {
      expect(
        OnboardingCoordinator.getPreviousRoute('/bogus'),
        isNull,
      );
    });

    test('getPreviousRoute from complete is notifications', () {
      expect(
        OnboardingCoordinator.getPreviousRoute('/onboarding/complete'),
        '/onboarding/notifications',
      );
    });

    // ---- getProgress ----

    test('getProgress for first step is 1/16', () {
      expect(
        OnboardingCoordinator.getProgress('/onboarding/phone'),
        closeTo(1 / 16, 0.001),
      );
    });

    test('getProgress for last step is 1.0', () {
      expect(
        OnboardingCoordinator.getProgress('/onboarding/complete'),
        1.0,
      );
    });

    test('getProgress for unknown route is 0.0', () {
      expect(
        OnboardingCoordinator.getProgress('/nope'),
        0.0,
      );
    });

    test('getProgress for middle step (gender, idx=5) is 6/16', () {
      expect(
        OnboardingCoordinator.getProgress('/onboarding/gender'),
        closeTo(6 / 16, 0.001),
      );
    });

    test('progress increases monotonically through all steps', () {
      double prev = 0.0;
      for (final step in OnboardingCoordinator.steps) {
        final p = OnboardingCoordinator.getProgress(step);
        expect(p, greaterThan(prev), reason: 'Progress should increase at $step');
        prev = p;
      }
    });

    // ---- isLastStep / isFirstStep ----

    test('isLastStep true only for /onboarding/complete', () {
      expect(OnboardingCoordinator.isLastStep('/onboarding/complete'), isTrue);
      expect(OnboardingCoordinator.isLastStep('/onboarding/phone'), isFalse);
      expect(OnboardingCoordinator.isLastStep('/onboarding/photos'), isFalse);
    });

    test('isFirstStep true only for /onboarding/phone', () {
      expect(OnboardingCoordinator.isFirstStep('/onboarding/phone'), isTrue);
      expect(OnboardingCoordinator.isFirstStep('/onboarding/complete'), isFalse);
    });

    // ---- indexOf ----

    test('indexOf returns correct index for each step', () {
      for (int i = 0; i < OnboardingCoordinator.steps.length; i++) {
        expect(OnboardingCoordinator.indexOf(OnboardingCoordinator.steps[i]), i);
      }
    });

    test('indexOf returns -1 for unknown route', () {
      expect(OnboardingCoordinator.indexOf('/unknown'), -1);
    });

    // ---- getRouteForStep ----

    test('getRouteForStep(1) returns first route', () {
      expect(
        OnboardingCoordinator.getRouteForStep(1),
        '/onboarding/phone',
      );
    });

    test('getRouteForStep(16) returns last route', () {
      expect(
        OnboardingCoordinator.getRouteForStep(16),
        '/onboarding/complete',
      );
    });

    test('getRouteForStep(0) returns null', () {
      expect(OnboardingCoordinator.getRouteForStep(0), isNull);
    });

    test('getRouteForStep(17) returns null', () {
      expect(OnboardingCoordinator.getRouteForStep(17), isNull);
    });

    // ---- getStepLabel ----

    test('getStepLabel for phone is "Step 1 of 16"', () {
      expect(
        OnboardingCoordinator.getStepLabel('/onboarding/phone'),
        'Step 1 of 16',
      );
    });

    test('getStepLabel for complete is "Step 16 of 16"', () {
      expect(
        OnboardingCoordinator.getStepLabel('/onboarding/complete'),
        'Step 16 of 16',
      );
    });

    test('getStepLabel for unknown route returns empty string', () {
      expect(OnboardingCoordinator.getStepLabel('/unknown'), '');
    });

    // ---- full flow traversal ----

    test('can traverse entire flow forward via getNextRoute', () {
      String? current = OnboardingCoordinator.steps.first;
      final visited = <String>[];
      while (current != null) {
        visited.add(current);
        current = OnboardingCoordinator.getNextRoute(current);
      }
      expect(visited, OnboardingCoordinator.steps);
    });

    test('can traverse entire flow backward via getPreviousRoute', () {
      String? current = OnboardingCoordinator.steps.last;
      final visited = <String>[];
      while (current != null) {
        visited.add(current);
        current = OnboardingCoordinator.getPreviousRoute(current);
      }
      expect(visited, OnboardingCoordinator.steps.reversed.toList());
    });

    // ---- step order correctness ----

    test('photos comes after about-me', () {
      final aboutMeIdx = OnboardingCoordinator.indexOf('/onboarding/about-me');
      final photosIdx = OnboardingCoordinator.indexOf('/onboarding/photos');
      expect(photosIdx, aboutMeIdx + 1);
    });

    test('location comes after photos', () {
      final photosIdx = OnboardingCoordinator.indexOf('/onboarding/photos');
      final locationIdx = OnboardingCoordinator.indexOf('/onboarding/location');
      expect(locationIdx, photosIdx + 1);
    });
  });
}
