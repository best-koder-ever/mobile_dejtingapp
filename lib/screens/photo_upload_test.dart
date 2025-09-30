import 'package:flutter/material.dart';
import 'photo_upload_screen.dart';

/// Simple test screen to demonstrate the unified PhotoUploadScreen with demo mode
class PhotoUploadTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Upload Tests'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Photo Upload Screen Tests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            // Demo Mode Button
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.science, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Demo Mode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Auto-login with Erik Astrom demo user. Perfect for testing without manual login.',
                      style: TextStyle(color: Colors.orange.shade600),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          _navigateToPhotoUpload(context, isDemoMode: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Test Demo Mode'),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Production Mode Button (requires manual auth)
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Production Mode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Requires manual authToken and userId. Use this in the real app flow.',
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showProductionModeDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Test Production Mode'),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Info card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Unified Photo Upload',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '✅ Single PhotoUploadScreen handles both demo and production modes\n'
                      '✅ Demo mode: Auto-login + demo UI indicators\n'
                      '✅ Production mode: Manual auth + clean UI\n'
                      '✅ No more duplicate demo wrapper screens!',
                      style: TextStyle(color: Colors.green.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPhotoUpload(BuildContext context, {bool isDemoMode = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoUploadScreen(
          isDemoMode: isDemoMode,
          onPhotoRequirementMet: (isComplete) {
            print('Photo requirements met: $isComplete');
          },
        ),
      ),
    );
  }

  void _showProductionModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Production Mode'),
        content: Text(
          'Production mode requires a valid authToken and userId.\n\n'
          'In the real app, you would get these from your authentication flow.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // For testing, use demo credentials but in production mode
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoUploadScreen(
                    authToken: 'your-jwt-token-here',
                    userId: 1,
                    isDemoMode: false,
                    onPhotoRequirementMet: (isComplete) {
                      print('Photo requirements met: $isComplete');
                    },
                  ),
                ),
              );
            },
            child: Text('Test with Mock Data'),
          ),
        ],
      ),
    );
  }
}
