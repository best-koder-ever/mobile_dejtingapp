import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/dev_mode_banner.dart';

/// Phone Number Entry Screen
/// Tinder-style single-field phone entry with country selector
class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  static const Color coralColor = Color(0xFFFF6B6B);

  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+46';
  String _selectedCountryFlag = '🇸🇪';
  bool _isValidPhone = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    setState(() {
      _isValidPhone = phone.length >= 9 && phone.length <= 15;
    });
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Country', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildCountryOption('🇸🇪', 'Sweden', '+46'),
            _buildCountryOption('🇺🇸', 'United States', '+1'),
            _buildCountryOption('🇬🇧', 'United Kingdom', '+44'),
            _buildCountryOption('🇩🇪', 'Germany', '+49'),
            _buildCountryOption('🇫🇷', 'France', '+33'),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryOption(String flag, String name, String code) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 32)),
      title: Text(name),
      trailing: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, color: coralColor)),
      onTap: () {
        setState(() {
          _selectedCountryFlag = flag;
          _selectedCountryCode = code;
        });
        Navigator.pop(context);
        _validatePhone();
      },
    );
  }

  void _handleContinue() {
    if (!_isValidPhone) return;
    Navigator.pushNamed(context, '/onboarding/verify-code');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B6B)),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Can we get your number?',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We\'ll send you a text with a verification code. '
                    'Message and data rates may apply.',
                    style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // Country selector + Phone input
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _showCountryPicker,
                          child: Row(
                            children: [
                              Text(_selectedCountryFlag, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 8),
                              Text(_selectedCountryCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            autofocus: true,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Phone number',
                              hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-()]')),
                              LengthLimitingTextInputFormatter(20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'When you tap "Continue", we\'ll send you a text with a verification code.',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isValidPhone ? _handleContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coralColor,
                        disabledBackgroundColor: Colors.grey[300],
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.grey[500],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: _isValidPhone ? 2 : 0,
                      ),
                      child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          DevModeSkipButton(
            onSkip: () => Navigator.pushNamed(context, '/onboarding/community-guidelines'),
            label: 'Skip Phone',
          ),
        ],
      ),
    );
  }
}
