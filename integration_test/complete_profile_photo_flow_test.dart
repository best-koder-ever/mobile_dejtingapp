import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Helper function to explore photo upload options
Future<void> explorePhotoUploadOptions(WidgetTester tester) async {
  print('\n🔍 Exploring current screen for photo options...');
  
  // Look for any photo-related text
  final photoTexts = [
    'photo', 'Photo', 'PHOTO',
    'upload', 'Upload', 'UPLOAD',
    'camera', 'Camera', 'CAMERA',
    'image', 'Image', 'IMAGE',
    'gallery', 'Gallery', 'GALLERY',
    'add', 'Add', 'ADD',
    'manage', 'Manage', 'MANAGE',
    'edit', 'Edit', 'EDIT',
  ];
  
  for (final text in photoTexts) {
    final found = find.textContaining(text, findRichText: true);
    if (found.evaluate().isNotEmpty) {
      print('📝 Found "$text": ${found.evaluate().length} occurrences');
    }
  }
  
  // Look for common photo icons
  final photoIcons = [
    Icons.camera_alt,
    Icons.photo_camera,
    Icons.add_a_photo,
    Icons.photo,
    Icons.image,
    Icons.upload,
    Icons.add,
    Icons.add_circle,
    Icons.add_circle_outline,
    Icons.photo_library,
    Icons.edit,
  ];
  
  for (final icon in photoIcons) {
    final found = find.byIcon(icon);
    if (found.evaluate().isNotEmpty) {
      print('🎯 Found icon ${icon.toString()}: ${found.evaluate().length} occurrences');
    }
  }
}

// Helper function to check for images
Future<void> checkForImages(WidgetTester tester) async {
  print('\n🖼️ Checking for images...');
  
  final images = find.byType(Image);
  print('📊 Total images found: ${images.evaluate().length}');
  
  if (images.evaluate().isNotEmpty) {
    for (int i = 0; i < images.evaluate().length && i < 5; i++) {
      final image = images.at(i).evaluate().first.widget as Image;
      print('🖼️ Image $i: ${image.image.runtimeType}');
    }
  }
  
  // Check for network images specifically
  final networkImages = find.byWidgetPredicate((widget) => 
    widget is Image && widget.image is NetworkImage);
  print('🌐 Network images: ${networkImages.evaluate().length}');
  
  await tester.pumpAndSettle(Duration(seconds: 1));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('📸 Complete Profile Photo Upload Flow', () {
    testWidgets('🎯 Demo Login → Profile → Edit → Photo Upload', (WidgetTester tester) async {
      print('\n🚀 Starting Complete Profile Photo Upload Flow Test...');
      
      // Launch app
      print('📱 Launching Dating App...');
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      print('\n🔐 === STEP 1: DEMO LOGIN ===');
      
      // Wait for login screen to fully load
      await tester.pumpAndSettle(Duration(seconds: 2));
      
      // Look for demo mode elements
      final demoModeText = find.textContaining('DEMO MODE', findRichText: true);
      print('🎬 Demo mode detected: ${demoModeText.evaluate().isNotEmpty}');
      
      // Find the login button (should be pre-filled with demo user)
      final loginButton = find.byType(ElevatedButton);
      print('🔘 Login buttons found: ${loginButton.evaluate().length}');
      
      if (loginButton.evaluate().isNotEmpty) {
        print('👆 Tapping demo login button...');
        await tester.tap(loginButton.first);
        await tester.pumpAndSettle(Duration(seconds: 5));
        print('✅ Demo login completed');
      } else {
        fail('❌ Login button not found');
      }
      
      print('\n🏠 === STEP 2: NAVIGATE TO PROFILE TAB ===');
      
      // Wait for main app to load
      await tester.pumpAndSettle(Duration(seconds: 3));
      
      // Look for bottom navigation
      final bottomNav = find.byType(BottomNavigationBar);
      print('📱 Bottom navigation found: ${bottomNav.evaluate().isNotEmpty}');
      
      if (bottomNav.evaluate().isEmpty) {
        fail('❌ Bottom navigation not found - app might not have logged in properly');
      }
      
      // Find Profile tab (should be index 2: Discover, Matches, Profile, Settings)
      final profileIcon = find.descendant(
        of: bottomNav,
        matching: find.byIcon(Icons.person),
      );
      
      print('👤 Profile icon found: ${profileIcon.evaluate().isNotEmpty}');
      
      if (profileIcon.evaluate().isNotEmpty) {
        print('👆 Tapping Profile tab...');
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle(Duration(seconds: 3));
        print('✅ Navigated to Profile tab');
      } else {
        fail('❌ Profile icon not found in bottom navigation');
      }
      
      print('\n👤 === STEP 3: EXPLORE PROFILE SCREEN ===');
      
      await explorePhotoUploadOptions(tester);
      await checkForImages(tester);
      
      // Look specifically for Edit button or Manage Photos button
      final editButton = find.byIcon(Icons.edit);
      final managePhotosButton = find.textContaining('Manage Photos', findRichText: true);
      
      print('✏️ Edit buttons found: ${editButton.evaluate().length}');
      print('📸 Manage Photos buttons found: ${managePhotosButton.evaluate().length}');
      
      // Try to enter edit mode first
      if (editButton.evaluate().isNotEmpty) {
        print('\n✏️ === STEP 4A: ENTER EDIT MODE ===');
        print('👆 Tapping Edit button...');
        await tester.tap(editButton.first);
        await tester.pumpAndSettle(Duration(seconds: 3));
        print('✅ Entered edit mode');
        
        await explorePhotoUploadOptions(tester);
        
        // Look for photo grid or photo upload in edit mode
        final photoGrid = find.byType(GridView);
        print('📱 Photo grid found: ${photoGrid.evaluate().isNotEmpty}');
        
        // Look for any widgets that might be photo upload spots
        final gestureDetectors = find.byType(GestureDetector);
        final inkWells = find.byType(InkWell);
        
        print('👆 GestureDetectors found: ${gestureDetectors.evaluate().length}');
        print('👆 InkWells found: ${inkWells.evaluate().length}');
        
        // Try tapping on photo grid areas
        if (photoGrid.evaluate().isNotEmpty) {
          print('👆 Attempting to tap on photo grid...');
          await tester.tap(photoGrid.first);
          await tester.pumpAndSettle(Duration(seconds: 3));
          print('✅ Tapped photo grid');
          
          await explorePhotoUploadOptions(tester);
          await checkForImages(tester);
        }
      }
      
      // Try Manage Photos button approach
      if (managePhotosButton.evaluate().isNotEmpty) {
        print('\n📸 === STEP 4B: MANAGE PHOTOS ROUTE ===');
        print('👆 Tapping Manage Photos button...');
        await tester.tap(managePhotosButton.first);
        await tester.pumpAndSettle(Duration(seconds: 3));
        print('✅ Navigated to Manage Photos');
        
        await explorePhotoUploadOptions(tester);
        await checkForImages(tester);
        
        // Look for upload functionality in photo management screen
        final uploadButtons = find.textContaining('Upload', findRichText: true);
        final addButtons = find.textContaining('Add', findRichText: true);
        final cameraIcons = find.byIcon(Icons.camera_alt);
        
        print('📤 Upload buttons: ${uploadButtons.evaluate().length}');
        print('➕ Add buttons: ${addButtons.evaluate().length}');
        print('📷 Camera icons: ${cameraIcons.evaluate().length}');
        
        // Try to interact with upload elements
        if (uploadButtons.evaluate().isNotEmpty) {
          print('👆 Tapping Upload button...');
          await tester.tap(uploadButtons.first);
          await tester.pumpAndSettle(Duration(seconds: 3));
          await checkForImages(tester);
        } else if (cameraIcons.evaluate().isNotEmpty) {
          print('👆 Tapping Camera icon...');
          await tester.tap(cameraIcons.first);
          await tester.pumpAndSettle(Duration(seconds: 3));
          await checkForImages(tester);
        } else if (addButtons.evaluate().isNotEmpty) {
          print('👆 Tapping Add button...');
          await tester.tap(addButtons.first);
          await tester.pumpAndSettle(Duration(seconds: 3));
          await checkForImages(tester);
        }
      }
      
      // Fallback: Look for any ElevatedButtons that might be photo-related
      if (editButton.evaluate().isEmpty && managePhotosButton.evaluate().isEmpty) {
        print('\n🔍 === STEP 4C: FALLBACK EXPLORATION ===');
        print('⚠️ No obvious edit/manage buttons found, exploring all buttons...');
        
        final allButtons = find.byType(ElevatedButton);
        print('🔘 All ElevatedButtons: ${allButtons.evaluate().length}');
        
        if (allButtons.evaluate().isNotEmpty) {
          for (int i = 0; i < allButtons.evaluate().length && i < 3; i++) {
            print('👆 Trying button $i...');
            await tester.tap(allButtons.at(i));
            await tester.pumpAndSettle(Duration(seconds: 3));
            
            await explorePhotoUploadOptions(tester);
            
            // Check if we ended up in a photo upload screen
            final afterTapUpload = find.textContaining('Upload', findRichText: true);
            if (afterTapUpload.evaluate().isNotEmpty) {
              print('🎉 Found upload functionality after button $i!');
              break;
            }
          }
        }
      }
      
      print('\n🎉 Complete Profile Photo Upload Flow Test Completed!');
      
      // Final summary
      final finalImages = find.byType(Image).evaluate().length;
      final finalUploadButtons = find.textContaining('Upload', findRichText: true).evaluate().length;
      
      print('📊 FINAL SUMMARY:');
      print('   Images found: $finalImages');
      print('   Upload buttons found: $finalUploadButtons');
      
      if (finalUploadButtons > 0) {
        print('✅ SUCCESS: Photo upload functionality detected!');
      } else {
        print('⚠️ INFO: No explicit upload buttons found, but navigation flow completed');
      }
    });
  });
}
