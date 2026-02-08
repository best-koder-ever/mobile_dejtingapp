import 'package:flutter/material.dart';

/// Community Guidelines Screen - Onboarding Step ONB-050
/// Shows house rules that users must accept before proceeding
class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // No back button - user must accept to proceed
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Welcome to DejTing.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please follow these House Rules.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              
              // Rules list
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRule(
                        'Be yourself',
                        'Use authentic photos and accurate information about yourself.',
                      ),
                      const SizedBox(height: 28),
                      _buildRule(
                        'Stay safe',
                        'Protect your personal information and report any suspicious behavior.',
                      ),
                      const SizedBox(height: 28),
                      _buildRule(
                        'Play it cool',
                        'Treat everyone with respect and kindness.',
                      ),
                      const SizedBox(height: 28),
                      _buildRule(
                        'Be proactive',
                        'Take initiative and make meaningful connections.',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // I agree button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Store acceptance in local state (backend integration later)
                    // Navigate to next screen in wizard
                    Navigator.pushNamed(context, '/onboarding/first-name');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: const Text(
                    'I agree',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRule(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkmark icon
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF00C878), // Green checkmark color
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 16),
        // Rule text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
