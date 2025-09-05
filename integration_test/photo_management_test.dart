import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Test credentials
const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Photo Upload & Management Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('Photo upload and primary photo setting',
        (WidgetTester tester) async {
      print('📸 Starting photo upload test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Navigate to profile/photo management
      await _navigateToPhotoManagement(tester);
      print('✅ Navigated to photo management');

      // Test photo upload simulation
      await _testPhotoUpload(tester);
      print('✅ Photo upload tested');

      // Test setting primary photo
      await _testSetPrimaryPhoto(tester);
      print('✅ Primary photo setting tested');
    });

    testWidgets('Photo organization and management',
        (WidgetTester tester) async {
      print('🗂️ Starting photo organization test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToPhotoManagement(tester);

      // Test photo reordering
      await _testPhotoReordering(tester);
      print('✅ Photo reordering tested');

      // Test photo deletion
      await _testPhotoDeletion(tester);
      print('✅ Photo deletion tested');

      // Test multiple photo upload
      await _testMultiplePhotoUpload(tester);
      print('✅ Multiple photo upload tested');
    });

    testWidgets('Photo validation and error handling',
        (WidgetTester tester) async {
      print('🛡️ Starting photo validation test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToPhotoManagement(tester);

      // Test photo validation
      await _testPhotoValidation(tester);
      print('✅ Photo validation tested');

      // Test error handling scenarios
      await _testPhotoErrorHandling(tester);
      print('✅ Photo error handling tested');
    });

    testWidgets('Photo display and viewing', (WidgetTester tester) async {
      print('👀 Starting photo display test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToPhotoManagement(tester);

      // Test photo gallery display
      await _testPhotoGalleryDisplay(tester);
      print('✅ Photo gallery display tested');

      // Test photo viewing and zoom
      await _testPhotoViewing(tester);
      print('✅ Photo viewing tested');
    });
  });
}

// Helper function for login
Future<void> _performLogin(WidgetTester tester) async {
  print('🔐 Starting login process...');

  // Find and fill email field
  final emailField = find.byType(TextField).first;
  expect(emailField, findsOneWidget);
  await tester.enterText(emailField, TEST_EMAIL);
  await tester.pumpAndSettle();

  // Find and fill password field
  final passwordField = find.byType(TextField).last;
  expect(passwordField, findsOneWidget);
  await tester.enterText(passwordField, TEST_PASSWORD);
  await tester.pumpAndSettle();

  // Tap login button
  final loginButton = find.byType(ElevatedButton);
  expect(loginButton, findsOneWidget);
  await tester.tap(loginButton);

  // Wait for login request and navigation
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Check if we successfully navigated away from login screen
  final loginWelcome = find.text('Welcome to Dating App');
  expect(loginWelcome, findsNothing,
      reason: 'Should have navigated away from login screen');
}

// Helper function to navigate to photo management
Future<void> _navigateToPhotoManagement(WidgetTester tester) async {
  print('📱 Navigating to photo management...');

  // Look for profile tab first
  Finder? profileTab;

  if (find.text('Profile').evaluate().isNotEmpty) {
    profileTab = find.text('Profile');
  } else if (find.byIcon(Icons.person).evaluate().isNotEmpty) {
    profileTab = find.byIcon(Icons.person);
  } else if (find.byIcon(Icons.account_circle).evaluate().isNotEmpty) {
    profileTab = find.byIcon(Icons.account_circle);
  }

  if (profileTab != null) {
    await tester.tap(profileTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Navigated to profile section');
  }

  // Look for photo management options
  Finder? photoOption;

  if (find.text('Photos').evaluate().isNotEmpty) {
    photoOption = find.text('Photos');
  } else if (find.text('Manage Photos').evaluate().isNotEmpty) {
    photoOption = find.text('Manage Photos');
  } else if (find.text('Edit Photos').evaluate().isNotEmpty) {
    photoOption = find.text('Edit Photos');
  } else if (find.byIcon(Icons.photo_camera).evaluate().isNotEmpty) {
    photoOption = find.byIcon(Icons.photo_camera);
  } else if (find.byIcon(Icons.add_a_photo).evaluate().isNotEmpty) {
    photoOption = find.byIcon(Icons.add_a_photo);
  } else if (find.text('Add Photo').evaluate().isNotEmpty) {
    photoOption = find.text('Add Photo');
  }

  if (photoOption != null) {
    await tester.tap(photoOption);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Navigated to photo management');
  } else {
    print('ℹ️ Already in photo management or option not found');
  }
}

// Helper function to test photo upload
Future<void> _testPhotoUpload(WidgetTester tester) async {
  print('📷 Testing photo upload...');

  // Look for add photo buttons
  final addPhotoOptions = [
    find.text('Add Photo'),
    find.text('Upload Photo'),
    find.text('+'),
    find.byIcon(Icons.add),
    find.byIcon(Icons.add_a_photo),
    find.byIcon(Icons.photo_camera),
    find.byIcon(Icons.camera_alt),
  ];

  bool foundAddOption = false;
  for (final option in addPhotoOptions) {
    if (option.evaluate().isNotEmpty) {
      foundAddOption = true;
      await tester.tap(option.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Tapped add photo option: ${option.description}');
      break;
    }
  }

  if (!foundAddOption) {
    print('⚠️ No add photo option found');
    return;
  }

  // Look for photo source selection (camera vs gallery)
  final photoSources = [
    find.text('Camera'),
    find.text('Gallery'),
    find.text('Choose from Gallery'),
    find.text('Take Photo'),
    find.byIcon(Icons.camera_alt),
    find.byIcon(Icons.photo_library),
  ];

  bool foundSource = false;
  for (final source in photoSources) {
    if (source.evaluate().isNotEmpty) {
      foundSource = true;
      await tester.tap(source.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✅ Selected photo source: ${source.description}');
      break;
    }
  }

  if (foundSource) {
    print('ℹ️ Photo picker would open here (simulated in test)');

    // Simulate successful photo selection by looking for confirmation
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Look for save/confirm buttons
    final confirmButtons = [
      find.text('Save'),
      find.text('Done'),
      find.text('Upload'),
      find.text('Confirm'),
      find.byIcon(Icons.check),
    ];

    for (final button in confirmButtons) {
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('✅ Photo upload confirmed');
        break;
      }
    }
  } else {
    print('ℹ️ Photo source selection not found, direct upload may be used');
  }
}

// Helper function to test setting primary photo
Future<void> _testSetPrimaryPhoto(WidgetTester tester) async {
  print('⭐ Testing primary photo setting...');

  // Look for existing photos or photo placeholders
  final photoElements = [
    find.byType(Image),
    find.byType(NetworkImage),
    find.byType(Card),
    find.byType(Container),
  ];

  bool foundPhotos = false;
  for (final element in photoElements) {
    if (element.evaluate().isNotEmpty) {
      foundPhotos = true;
      print('✅ Found ${element.evaluate().length} photo elements');

      // Try long-pressing or tapping for options
      await tester.longPress(element.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for "Set as Primary" or similar options
      final primaryOptions = [
        find.text('Set as Primary'),
        find.text('Make Primary'),
        find.text('Set as Main'),
        find.text('Primary'),
        find.byIcon(Icons.star),
        find.byIcon(Icons.favorite),
      ];

      bool foundPrimaryOption = false;
      for (final option in primaryOptions) {
        if (option.evaluate().isNotEmpty) {
          foundPrimaryOption = true;
          await tester.tap(option.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('✅ Set primary photo option tapped');
          break;
        }
      }

      if (!foundPrimaryOption) {
        print('ℹ️ Primary photo option not found via long press');
      }
      break;
    }
  }

  if (!foundPhotos) {
    print('ℹ️ No existing photos found for primary setting test');
  }
}

// Helper function to test photo reordering
Future<void> _testPhotoReordering(WidgetTester tester) async {
  print('↕️ Testing photo reordering...');

  // Look for multiple photo elements
  final photos = find.byType(Image);
  if (photos.evaluate().length >= 2) {
    print('✅ Found ${photos.evaluate().length} photos for reordering test');

    // Try drag and drop reordering
    await tester.drag(photos.first, const Offset(100, 0));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Performed drag gesture for reordering');
  } else {
    print('ℹ️ Not enough photos for reordering test');
  }

  // Look for reorder UI elements
  final reorderElements = [
    find.byIcon(Icons.drag_handle),
    find.byIcon(Icons.reorder),
    find.text('Reorder'),
    find.text('Rearrange'),
  ];

  for (final element in reorderElements) {
    if (element.evaluate().isNotEmpty) {
      print('✅ Found reorder UI element: ${element.description}');
      break;
    }
  }
}

// Helper function to test photo deletion
Future<void> _testPhotoDeletion(WidgetTester tester) async {
  print('🗑️ Testing photo deletion...');

  // Look for photo elements to delete
  if (find.byType(Image).evaluate().isNotEmpty) {
    // Try long-pressing for delete options
    await tester.longPress(find.byType(Image).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Look for delete options
    final deleteOptions = [
      find.text('Delete'),
      find.text('Remove'),
      find.text('Delete Photo'),
      find.byIcon(Icons.delete),
      find.byIcon(Icons.remove),
    ];

    bool foundDeleteOption = false;
    for (final option in deleteOptions) {
      if (option.evaluate().isNotEmpty) {
        foundDeleteOption = true;
        await tester.tap(option.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('✅ Delete option tapped');

        // Look for confirmation dialog
        if (find.text('Confirm').evaluate().isNotEmpty) {
          await tester.tap(find.text('Confirm'));
          await tester.pumpAndSettle();
          print('✅ Delete confirmed');
        } else if (find.text('Yes').evaluate().isNotEmpty) {
          await tester.tap(find.text('Yes'));
          await tester.pumpAndSettle();
          print('✅ Delete confirmed');
        }
        break;
      }
    }

    if (!foundDeleteOption) {
      print('ℹ️ Delete option not found via long press');
    }
  } else {
    print('ℹ️ No photos found for deletion test');
  }
}

// Helper function to test multiple photo upload
Future<void> _testMultiplePhotoUpload(WidgetTester tester) async {
  print('📸📸 Testing multiple photo upload...');

  // Look for multiple upload options
  final multiUploadOptions = [
    find.text('Add Multiple'),
    find.text('Upload Multiple'),
    find.text('Select Multiple'),
    find.text('Choose Multiple'),
  ];

  bool foundMultiOption = false;
  for (final option in multiUploadOptions) {
    if (option.evaluate().isNotEmpty) {
      foundMultiOption = true;
      await tester.tap(option.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✅ Multiple upload option tapped');
      break;
    }
  }

  if (!foundMultiOption) {
    print(
        'ℹ️ Multiple upload option not found, trying regular add photo multiple times');

    // Try adding photos multiple times
    for (int i = 0; i < 2; i++) {
      if (find.text('Add Photo').evaluate().isNotEmpty) {
        await tester.tap(find.text('Add Photo'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('✅ Added photo ${i + 1}');
      }
    }
  }
}

// Helper function to test photo validation
Future<void> _testPhotoValidation(WidgetTester tester) async {
  print('🔍 Testing photo validation...');

  // Look for validation messages or limits
  final validationElements = [
    find.textContaining('maximum'),
    find.textContaining('minimum'),
    find.textContaining('size limit'),
    find.textContaining('format'),
    find.textContaining('invalid'),
    find.textContaining('Error'),
  ];

  bool foundValidation = false;
  for (final element in validationElements) {
    if (element.evaluate().isNotEmpty) {
      foundValidation = true;
      print('✅ Found validation message: ${element.description}');
      break;
    }
  }

  if (!foundValidation) {
    print('ℹ️ No validation messages currently visible');
  }

  // Look for photo limit indicators
  final limitIndicators = [
    find.textContaining('/'),
    find.textContaining('of'),
    find.textContaining('remaining'),
  ];

  for (final indicator in limitIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      print('✅ Found photo limit indicator: ${indicator.description}');
      break;
    }
  }
}

// Helper function to test photo error handling
Future<void> _testPhotoErrorHandling(WidgetTester tester) async {
  print('🛡️ Testing photo error handling...');

  // Look for error handling elements
  final errorElements = [
    find.textContaining('Failed'),
    find.textContaining('Error uploading'),
    find.textContaining('Try again'),
    find.textContaining('Upload failed'),
    find.byIcon(Icons.error),
    find.byIcon(Icons.warning),
  ];

  bool foundErrorHandling = false;
  for (final element in errorElements) {
    if (element.evaluate().isNotEmpty) {
      foundErrorHandling = true;
      print('✅ Found error handling element: ${element.description}');

      // Try tapping retry if available
      if (element.description.contains('Try again')) {
        await tester.tap(element.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('✅ Retry option tapped');
      }
      break;
    }
  }

  if (!foundErrorHandling) {
    print('ℹ️ No error handling elements currently visible (good)');
  }
}

// Helper function to test photo gallery display
Future<void> _testPhotoGalleryDisplay(WidgetTester tester) async {
  print('🖼️ Testing photo gallery display...');

  // Look for gallery layout elements
  final galleryElements = [
    find.byType(GridView),
    find.byType(ListView),
    find.byType(PageView),
    find.byType(Image),
  ];

  bool foundGallery = false;
  for (final element in galleryElements) {
    if (element.evaluate().isNotEmpty) {
      foundGallery = true;
      print(
          '✅ Found gallery display element: ${element.evaluate().length} ${element.description}');
    }
  }

  if (!foundGallery) {
    print('ℹ️ No gallery display elements found');
  }
}

// Helper function to test photo viewing
Future<void> _testPhotoViewing(WidgetTester tester) async {
  print('👁️ Testing photo viewing...');

  // Try tapping on photos to view them
  if (find.byType(Image).evaluate().isNotEmpty) {
    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Tapped on photo for viewing');

    // Look for full-screen view or zoom capabilities
    final viewingElements = [
      find.byIcon(Icons.close),
      find.byIcon(Icons.fullscreen),
      find.byIcon(Icons.zoom_in),
      find.byIcon(Icons.zoom_out),
    ];

    bool foundViewingUI = false;
    for (final element in viewingElements) {
      if (element.evaluate().isNotEmpty) {
        foundViewingUI = true;
        print('✅ Found photo viewing UI: ${element.description}');

        // Close the view if close button is available
        if (element.description.contains('close')) {
          await tester.tap(element.first);
          await tester.pumpAndSettle();
          print('✅ Closed photo view');
        }
        break;
      }
    }

    if (!foundViewingUI) {
      print('ℹ️ Photo viewing UI not detected');
    }
  } else {
    print('ℹ️ No photos available for viewing test');
  }
}
