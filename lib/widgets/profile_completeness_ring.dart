import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Profile Completeness Progress Ring (T154)
/// A circular progress ring widget showing profile completeness percentage.
/// Color codes: red (<50%), amber (50-80%), green (>80%).
class ProfileCompletenessRing extends StatelessWidget {
  const ProfileCompletenessRing({
    super.key,
    required this.percentage,
    this.size = 120.0,
    this.strokeWidth = 8.0,
    this.showNudge = true,
  });

  /// Profile completeness 0.0 – 1.0
  final double percentage;
  final double size;
  final double strokeWidth;
  final bool showNudge;

  Color get _ringColor {
    if (percentage < 0.5) return const Color(0xFFE53935); // red
    if (percentage < 0.8) return const Color(0xFFFFA726); // amber
    return const Color(0xFF66BB6A); // green
  }

  String get _nudgeMessage {
    if (percentage >= 1.0) return 'Profile complete! 🎉';
    if (percentage >= 0.8) return 'Almost there — add a few more details';
    if (percentage >= 0.5) return 'Looking good — keep going!';
    return 'Add more info to get matches';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (percentage * 100).round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: strokeWidth,
                  color: Colors.grey[200],
                ),
              ),
              // Progress arc
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: percentage.clamp(0.0, 1.0),
                  strokeWidth: strokeWidth,
                  color: _ringColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Percentage text in center
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.bold,
                      color: _ringColor,
                    ),
                  ),
                  Text(
                    'complete',
                    style: TextStyle(
                      fontSize: size * 0.1,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showNudge) ...[
          const SizedBox(height: 12),
          Text(
            _nudgeMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
