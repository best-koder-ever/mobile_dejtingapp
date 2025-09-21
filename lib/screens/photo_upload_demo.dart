import 'package:flutter/material.dart';
import '../services/demo_service.dart';
import '../services/photo_service.dart';
import 'photo_upload_screen.dart';

class PhotoUploadDemo extends StatefulWidget {
  @override
  State<PhotoUploadDemo> createState() => _PhotoUploadDemoState();
}

class _PhotoUploadDemoState extends State<PhotoUploadDemo> {
  bool photoRequirementMet = false;
  String? authToken;
  int? userId;
  bool isLoading = true;
  String? errorMessage;
  PhotoService photoService = PhotoService();

  @override
  void initState() {
    super.initState();
    _initializeDemo();
  }

  Future<void> _initializeDemo() async {
    try {
      // Check if PhotoService is running
      final isServiceHealthy = await photoService.isServiceHealthy();
      if (!isServiceHealthy) {
        setState(() {
          errorMessage =
              'PhotoService not running on port 8084.\nPlease start it with: docker-compose up photo-service';
          isLoading = false;
        });
        return;
      }

      // Auto-login with demo user for testing
      final result =
          await DemoService.loginWithDemoUser('erik.astrom@demo.com');

      if (result.success && result.token != null) {
        setState(() {
          authToken = result.token;
          userId = 1; // Default to user ID 1 for demo
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to login with demo user: ${result.message}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Initialization failed: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.pink),
              SizedBox(height: 16),
              Text('Initializing photo upload demo...'),
              SizedBox(height: 8),
              Text(
                'Checking PhotoService connection...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Photo Upload Demo'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Demo Setup Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    _initializeDemo();
                  },
                  child: Text('Retry'),
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Setup Instructions:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('1. Start PhotoService:'),
                        Text('   cd /home/m/development/DatingApp'),
                        Text('   docker-compose up photo-service'),
                        SizedBox(height: 8),
                        Text('2. Ensure demo backend is running:'),
                        Text(
                            '   DEMO_MODE=true docker-compose up auth-service'),
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

    return Scaffold(
      body: Column(
        children: [
          // Demo header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.orange.shade100,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.science, color: Colors.orange.shade700),
                      SizedBox(width: 8),
                      Text(
                        'PHOTO UPLOAD DEMO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Logged in as Erik Astrom (Demo User)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PhotoService: http://localhost:8084',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Photo upload screen
          Expanded(
            child: PhotoUploadScreen(
              authToken: authToken!,
              userId: userId!,
              onPhotoRequirementMet: (isComplete) {
                setState(() => photoRequirementMet = isComplete);
              },
            ),
          ),

          // Continue button (simulates onboarding flow)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Status indicator
                  Row(
                    children: [
                      Icon(
                        photoRequirementMet
                            ? Icons.check_circle
                            : Icons.warning,
                        color:
                            photoRequirementMet ? Colors.green : Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        photoRequirementMet
                            ? 'Photo requirements met!'
                            : 'Add at least 4 photos to continue',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: photoRequirementMet
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: photoRequirementMet ? _continueToNextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          photoRequirementMet ? Colors.pink : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      photoRequirementMet
                          ? 'Continue to Preferences'
                          : 'Upload more photos to continue',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _continueToNextStep() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Photo requirements met!'),
            SizedBox(height: 8),
            Text('Ready for next onboarding step:'),
            SizedBox(height: 8),
            Text('• Set preferences (age range, distance)'),
            Text('• Choose interests'),
            Text('• Start swiping!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue Demo'),
          ),
        ],
      ),
    );
  }
}
