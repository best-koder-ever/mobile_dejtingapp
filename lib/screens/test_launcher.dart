import 'package:flutter/material.dart';

/// Test Launcher Screen - Easy access to all photo upload tests
class TestLauncherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Upload Tests'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '🚀 Photo Upload Testing Suite',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),

            // Automated Test Button
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.play_circle_fill, size: 48, color: Colors.green),
                    SizedBox(height: 12),
                    Text(
                      'Automated Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Automatically tests all photo upload components:\n'
                      '• Authentication\n'
                      '• Service connectivity\n'
                      '• API endpoints',
                      style: TextStyle(color: Colors.green.shade600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/auto-photo-test'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text('Start Automated Test'),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // REAL Photo Upload Button
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.camera_alt, size: 48, color: Colors.red),
                    SizedBox(height: 12),
                    Text(
                      'REAL Photo Upload',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ACTUAL file upload and photo grid:\n'
                      '• Real image picker\n'
                      '• Real HTTP upload\n'
                      '• Real photo display',
                      style: TextStyle(color: Colors.red.shade600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/real-photo-upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text('🔥 TRY REAL UPLOAD'),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Manual Test Button
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.touch_app, size: 48, color: Colors.blue),
                    SizedBox(height: 12),
                    Text(
                      'Manual Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Original photo upload screen with:\n'
                      '• Demo mode\n'
                      '• Production mode\n'
                      '• Manual file selection',
                      style: TextStyle(color: Colors.blue.shade600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/photo-test'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text('Open Manual Test'),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Info card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'How This Works',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Start with AUTOMATED TEST to verify all components work\n'
                      '2. If automated test passes, the manual test should work too\n'
                      '3. Compare working automated flow with manual issues\n'
                      '4. Fix manual UI based on working automated flow',
                      style: TextStyle(color: Colors.orange.shade600),
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
}
