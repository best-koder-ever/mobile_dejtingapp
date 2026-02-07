import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Phone Number Entry Screen - TASK-010
/// Tinder-style single-field phone entry
/// 
/// Features:
/// - Country selector with flag and dial code
/// - Phone number input with validation
/// - Real-time formatting
/// - Continue button (disabled until valid)
class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  // Brand colors
  static const Color coralColor = Color(0xFFFF7F50);
  static const Color purpleColor = Color(0xFF7f13ec);
  
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+1'; // Default USA
  String _selectedCountryFlag = '🇺🇸';
  String _selectedCountryName = 'United States';
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
    // Basic validation - just check length for now
    // TODO: Use phone_number package for proper validation
    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    setState(() {
      // US: 10 digits, Sweden (+46): 9-10 digits
      _isValidPhone = phone.length >= 9 && phone.length <= 15;
    });
  }

  void _showCountryPicker() {
    // TODO: TASK-011 - Implement full country picker
    // For now, show simple dialog with common countries
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Country',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCountryOption('🇺🇸', 'United States', '+1'),
            _buildCountryOption('🇸🇪', 'Sweden', '+46'),
            _buildCountryOption('🇬🇧', 'United Kingdom', '+44'),
            _buildCountryOption('🇩🇪', 'Germany', '+49'),
            _buildCountryOption('🇫🇷', 'France', '+33'),
            const SizedBox(height: 16),
            Text(
              'Full country picker coming soon',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryOption(String flag, String name, String code) {
    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 32),
      ),
      title: Text(name),
      trailing: Text(
        code,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: coralColor,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedCountryFlag = flag;
          _selectedCountryName = name;
          _selectedCountryCode = code;
        });
        Navigator.pop(context);
        _validatePhone(); // Re-validate with new country
      },
    );
  }

  void _handleContinue() {
    if (!_isValidPhone) return;
    
    // TODO: TASK-013 - Send to backend for SMS verification
    final fullPhone = '$_selectedCountryCode${_phoneController.text}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sending verification code to $fullPhone...'),
        backgroundColor: coralColor,
      ),
    );
    
    // TODO: Navigate to SMS verification screen
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Can we get your number?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              
              // Explanation
              const Text(
                'We\'ll send you a text with a verification code. '
                'Message and data rates may apply.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
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
                    // Country selector button
                    InkWell(
                      onTap: _showCountryPicker,
                      child: Row(
                        children: [
                          Text(
                            _selectedCountryFlag,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedCountryCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Vertical divider
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(width: 12),
                    
                    // Phone number input
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Phone number',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
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
              
              // SMS warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'When you tap "Continue", we\'ll send you a text with a verification code.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Continue button
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: _isValidPhone ? 2 : 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
