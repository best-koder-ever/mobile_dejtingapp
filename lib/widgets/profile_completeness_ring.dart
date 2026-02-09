  import 'package:flutter/material.dart';

  /// Profile Completeness Progress Ring (T154)
  /// Auto-generated from task queue. Acceptance criteria:
    // - ProfileCompletenessRing StatelessWidget
// - Color coding: red (<50%), amber (50-80%), green (>80%)
// - Percentage text in center, nudge messages below
// - flutter analyze passes without errors
  class ProfileCompletenessProgressRingScreen extends StatefulWidget {
    const ProfileCompletenessProgressRingScreen({super.key});

    @override
    State<ProfileCompletenessProgressRingScreen> createState() => _ProfileCompletenessProgressRingScreenState();
  }

  class _ProfileCompletenessProgressRingScreenState extends State<ProfileCompletenessProgressRingScreen> {
    bool _isValid = false;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Profile Completeness Progress Ring',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // TODO: Implement screen body per acceptance criteria
                const Expanded(
                  child: Center(
                    child: Text('TODO: Implement T154 body'),
                  ),
                ),
                // Next button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isValid ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text('Next', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }
  }
