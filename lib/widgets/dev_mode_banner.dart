import 'package:flutter/material.dart';
import '../config/dev_mode.dart';

/// A floating "Skip" button shown only in DevMode.
/// Place this in a Stack on every onboarding screen.
/// [onSkip] should auto-fill fake data and navigate forward.
class DevModeSkipButton extends StatelessWidget {
  final VoidCallback onSkip;
  final String label;

  const DevModeSkipButton({
    super.key,
    required this.onSkip,
    this.label = 'Skip →',
  });

  @override
  Widget build(BuildContext context) {
    if (!DevMode.enabled) return const SizedBox.shrink();

    return Positioned(
      top: 8,
      right: 8,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSkip,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bug_report, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A dev mode banner at the top of the screen showing current route
class DevModeBanner extends StatelessWidget {
  const DevModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!DevMode.enabled) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2),
      color: Colors.orange,
      child: const Text(
        '🐛 DEV MODE — Skip buttons enabled',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
