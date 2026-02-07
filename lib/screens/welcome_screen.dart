import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'wizard/phone_entry_screen.dart';

/// Welcome/Login Screen - Based on Stitch variant-02-multiauth design
/// Changes from variant-01:
/// - Removed: "92% match accuracy", "Privacy First", "Real Conversations"
/// - Added: Google auth, Phone auth, App store links
/// - Changed: Dark modal overlay (Tinder-style)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Brand colors from design system
  static const Color coralColor = Color(0xFFFF7F50);
  static const Color purpleColor = Color(0xFF7f13ec);
  static const Color googleBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Coral-to-purple gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [coralColor, purpleColor],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background image (blurred romantic couple photo - placeholder)
              // TODO: Add actual background image asset
              // Positioned.fill(
              //   child: Opacity(
              //     opacity: 0.3,
              //     child: Container(
              //       decoration: const BoxDecoration(
              //         image: DecorationImage(
              //           image: AssetImage('assets/images/couple_bg.jpg'),
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              
              // Dark modal overlay (Tinder-style)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button (top-right)
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      
                      // Flame icon (coral)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: coralColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Heading
                      const Text(
                        'Create account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Terms agreement text (TASK-003: Now clickable!)
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'By tapping Log In or Continue, you agree to our '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => _openUrl('https://dejtingapp.com/terms'),
                                child: const Text(
                                  'Terms',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: coralColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: '. Learn how we process your data in our '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => _openUrl('https://dejtingapp.com/privacy'),
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: coralColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ', and '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => _openUrl('https://dejtingapp.com/cookies'),
                                child: const Text(
                                  'Cookie Policy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: coralColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // TASK-001: Apple Sign-In button (Required on iOS!)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement Apple Sign-In OAuth
                            _showComingSoon(context, 'Apple Sign-In');
                          },
                          icon: const Icon(Icons.apple, size: 24),
                          label: const Text('Continue with Apple'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(color: Colors.white30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Secondary: Continue with Google button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement Google OAuth
                            _showComingSoon(context, 'Google Sign-In');
                          },
                          icon: Image.asset(
                            'assets/images/google_logo.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.g_mobiledata, size: 24),
                          ),
                          label: const Text('Continue with Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: googleBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // TASK-002: Sign in with phone number (Tinder-style)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to phone entry screen (TASK-010 implemented!)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PhoneEntryScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone, size: 20),
                          label: const Text('Sign in with phone number'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[900],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(color: Colors.white30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Trouble Logging In? link
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password flow
                          _showComingSoon(context, 'Password Recovery');
                        },
                        child: const Text(
                          'Trouble Logging In?',
                          style: TextStyle(
                            color: coralColor,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Get the app! section
                      const Text(
                        'Get the app!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // App store buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Apple App Store
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // TODO: Open App Store URL
                                _showComingSoon(context, 'App Store');
                              },
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.apple, color: Colors.white, size: 24),
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Download on the',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          'App Store',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Google Play Store
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // TODO: Open Play Store URL
                                _showComingSoon(context, 'Play Store');
                              },
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow, color: Colors.white, size: 24),
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'GET IT ON',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          'Google Play',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: coralColor,
      ),
    );
  }
  // TASK-003: Open legal document URLs
  Future<void> _openUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
