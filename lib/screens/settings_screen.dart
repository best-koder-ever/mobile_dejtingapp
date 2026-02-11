import 'package:flutter/material.dart';
import 'package:dejtingapp/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _showMeOnTinder = true;
  bool _showAgeInProfile = true;
  bool _showDistanceInProfile = true;
  double _maxDistance = 50.0;
  RangeValues _ageRange = const RangeValues(18, 35);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // Uses theme default AppBar
        // Uses theme default foreground
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person, color: AppTheme.primaryColor),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update your photos and bio'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user, color: AppTheme.primaryColor),
            title: const Text('Verify Your Account'),
            subtitle: const Text('Get a blue checkmark'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Verification flow
            },
          ),
          ListTile(
            leading: const Icon(Icons.security, color: AppTheme.primaryColor),
            title: const Text('Privacy & Security'),
            subtitle: const Text('Control your privacy settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Privacy settings
            },
          ),

          const Divider(height: 32),

          // Discovery Settings
          _buildSectionHeader('Discovery Settings'),
          ListTile(
            leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
            title: const Text('Location'),
            subtitle: const Text('Update your location'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Location settings
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maximum Distance: ${_maxDistance.round()} km',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Slider(
                  value: _maxDistance,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _maxDistance = value;
                    });
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                RangeSlider(
                  values: _ageRange,
                  min: 18,
                  max: 80,
                  divisions: 62,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (values) {
                    setState(() {
                      _ageRange = values;
                    });
                  },
                ),
              ],
            ),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.visibility, color: AppTheme.primaryColor),
            title: const Text('Show me on DejTing'),
            subtitle: const Text('Turn off to pause your account'),
            value: _showMeOnTinder,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() {
                _showMeOnTinder = value;
              });
            },
          ),

          const Divider(height: 32),

          // Notifications
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: AppTheme.primaryColor),
            title: const Text('Push Notifications'),
            subtitle: const Text('New matches and messages'),
            value: _pushNotifications,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),

          const Divider(height: 32),

          // Profile Display
          _buildSectionHeader('Profile Display'),
          SwitchListTile(
            secondary: const Icon(Icons.cake, color: AppTheme.primaryColor),
            title: const Text('Show Age'),
            subtitle: const Text('Display your age on your profile'),
            value: _showAgeInProfile,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() {
                _showAgeInProfile = value;
              });
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.location_on, color: AppTheme.primaryColor),
            title: const Text('Show Distance'),
            subtitle: const Text('Display distance on your profile'),
            value: _showDistanceInProfile,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() {
                _showDistanceInProfile = value;
              });
            },
          ),

          const Divider(height: 32),

          // Support & About
          _buildSectionHeader('Support & About'),
          ListTile(
            leading: const Icon(Icons.help, color: AppTheme.primaryColor),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Help screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: AppTheme.primaryColor),
            title: const Text('About'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: AppTheme.primaryColor),
            title: const Text('Rate Us'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Rate app
            },
          ),

          const SizedBox(height: 32),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _showLogoutDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                // Uses theme default foreground
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Logout'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About DatingApp'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Version: 1.0.0'),
                SizedBox(height: 8),
                Text('Find your perfect match with our AI-powered dating app.'),
                SizedBox(height: 16),
                Text('Made with ❤️ by the DatingApp Team'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement logout
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
