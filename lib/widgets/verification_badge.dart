import 'package:flutter/material.dart';

/// Verification Badge Display Widget (T158)
/// Blue checkmark badge for verified users, with CTA for unverified.
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({
    super.key,
    required this.isVerified,
    this.size = 20.0,
    this.showLabel = false,
  });

  final bool isVerified;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();
    return Tooltip(
      message: 'Verified profile',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Color(0xFF1E88E5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: size * 0.65,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(
                fontSize: size * 0.6,
                color: const Color(0xFF1E88E5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// CTA button for unverified users to start verification.
class GetVerifiedButton extends StatelessWidget {
  const GetVerifiedButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.verified_outlined, color: Color(0xFF1E88E5)),
      label: const Text(
        'Get Verified',
        style: TextStyle(
          color: Color(0xFF1E88E5),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF1E88E5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
