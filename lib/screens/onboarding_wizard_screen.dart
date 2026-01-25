import 'package:flutter/material.dart';
import '../models/wizard_models.dart';
import 'wizard_steps/basic_info_step.dart';
import 'wizard_steps/preferences_step.dart';
import 'wizard_steps/photos_step.dart';

/// Main onboarding wizard screen coordinating 3-step user profile creation
/// Matches backend wizard endpoints: PATCH /api/wizard/step/{1,2,3}
class OnboardingWizardScreen extends StatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  WizardProgress _progress = WizardProgress();

  // Step data
  WizardStepBasicInfoDto? _basicInfo;
  WizardStepPreferencesDto? _preferences;
  WizardStepPhotosDto? _photos;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Confirm exit if progress exists
        if (_progress.step1Complete || _progress.step2Complete || _progress.step3Complete) {
          return await _confirmExit(context);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getStepTitle()),
          backgroundColor: Colors.pink[400],
          foregroundColor: Colors.white,
          elevation: 0,
          leading: _progress.canGoBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goBack,
                )
              : null,
        ),
        body: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: _progress.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
              minHeight: 8,
            ),
            // Step counter
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Step ${_progress.stepIndex + 1} of 3',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.circle, size: 6, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    _getStepSubtitle(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Current step widget
            Expanded(
              child: _buildCurrentStep(),
            ),
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_progress.currentStep) {
      case WizardStep.basicInfo:
        return BasicInfoStep(
          initialData: _basicInfo,
          onDataChanged: (data) {
            setState(() {
              _basicInfo = data;
              _progress = _progress.copyWith(step1Complete: data.isValid());
            });
          },
        );
      case WizardStep.preferences:
        return PreferencesStep(
          initialData: _preferences,
          onDataChanged: (data) {
            setState(() {
              _preferences = data;
              _progress = _progress.copyWith(step2Complete: data.isValid());
            });
          },
        );
      case WizardStep.photos:
        return PhotosStep(
          initialData: _photos,
          onDataChanged: (data) {
            setState(() {
              _photos = data;
              _progress = _progress.copyWith(step3Complete: data.isValid());
            });
          },
        );
    }
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button (except on first step)
          if (_progress.canGoBack) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _goBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.pink[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 16),
          ],
          // Continue/Complete button
          Expanded(
            flex: _progress.canGoBack ? 1 : 2,
            child: ElevatedButton(
              onPressed: _progress.canProceed ? _proceed : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.pink[400],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _progress.currentStep == WizardStep.photos
                        ? 'Complete Profile'
                        : 'Continue',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (_progress.currentStep != WizardStep.photos) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_progress.currentStep) {
      case WizardStep.basicInfo:
        return 'Basic Info';
      case WizardStep.preferences:
        return 'Your Preferences';
      case WizardStep.photos:
        return 'Add Photos';
    }
  }

  String _getStepSubtitle() {
    switch (_progress.currentStep) {
      case WizardStep.basicInfo:
        return 'Tell us about yourself';
      case WizardStep.preferences:
        return 'Who are you looking for?';
      case WizardStep.photos:
        return 'Show your best self';
    }
  }

  void _goBack() {
    final previousStep = _progress.previousStep;
    if (previousStep != null) {
      setState(() {
        _progress = _progress.copyWith(currentStep: previousStep);
      });
    }
  }

  Future<void> _proceed() async {
    // T027: Log analytics event for wizard step completion
    debugPrint('Wizard step ${_progress.stepIndex + 1} completed');

    if (_progress.currentStep == WizardStep.photos) {
      // Final step - submit all data
      await _completeWizard();
    } else {
      // Move to next step
      final nextStep = _progress.nextStep;
      if (nextStep != null) {
        // TODO: Call backend PATCH /api/wizard/step/{stepNumber} to persist progress
        setState(() {
          _progress = _progress.copyWith(currentStep: nextStep);
        });
      }
    }
  }

  Future<void> _completeWizard() async {
    // T027: Log analytics event for wizard completion
    debugPrint('Wizard completed by user');

    // TODO: Call backend PATCH /api/wizard/step/3 to mark profile as Ready
    // For now, show success and navigate to home
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.celebration, color: Colors.pink[400], size: 32),
              const SizedBox(width: 12),
              const Text('Welcome!'),
            ],
          ),
          content: const Text(
            'Your profile is ready! Let\'s start matching you with amazing people.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // TODO: Navigate to home screen with matchmaking enabled
                // For now, go back to login
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start Matching', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Wizard?'),
        content: const Text(
          'Your progress will be saved. You can resume setup anytime from your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
