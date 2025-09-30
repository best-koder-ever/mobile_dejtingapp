import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🔧 Photo Service Upload Fix', () {
    testWidgets('📸 Test Photo Upload to Dedicated Service', (WidgetTester tester) async {
      print('\n🚀 Testing Photo Upload to Dedicated Photo Service...');
      
      // Launch app
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      print('\n🔐 === DEMO LOGIN ===');
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton.first);
      await tester.pumpAndSettle(Duration(seconds: 5));
      print('✅ Logged in as demo user');
      
      print('\n🏠 === NAVIGATE TO PROFILE ===');
      final bottomNav = find.byType(BottomNavigationBar);
      final profileIcon = find.descendant(of: bottomNav, matching: find.byIcon(Icons.person));
      await tester.tap(profileIcon.first);
      await tester.pumpAndSettle(Duration(seconds: 3));
      print('✅ In Profile screen');
      
      print('\n📸 === TEST PHOTO UPLOAD WITH DEDICATED SERVICE ===');
      
      final addPhotoElements = find.textContaining('Add Photo', findRichText: true);
      print('📷 Available photo slots: ${addPhotoElements.evaluate().length}');
      
      if (addPhotoElements.evaluate().isNotEmpty) {
        print('👆 Uploading to first slot...');
        
        // Track image count before upload
        final imagesBefore = find.byType(Image);
        print('🖼️ Images before upload: ${imagesBefore.evaluate().length}');
        
        await tester.tap(addPhotoElements.first);
        await tester.pumpAndSettle(Duration(seconds: 2));
        
        // Check for uploading indicator
        final uploadingText = find.textContaining('Uploading', findRichText: true);
        print('⏳ Upload in progress: ${uploadingText.evaluate().length > 0}');
        
        if (uploadingText.evaluate().length > 0) {
          print('⏳ Waiting for upload to complete...');
          await tester.pumpAndSettle(Duration(seconds: 8));
        }
        
        // Check for success message
        final successMessages = find.textContaining('uploaded', findRichText: true);
        final errorMessages = find.textContaining('Failed', findRichText: true);
        
        print('✅ Success messages: ${successMessages.evaluate().length}');
        print('❌ Error messages: ${errorMessages.evaluate().length}');
        
        // Most importantly - check if images are now visible
        final imagesAfter = find.byType(Image);
        print('🖼️ Images after upload: ${imagesAfter.evaluate().length}');
        
        final imageIncrease = imagesAfter.evaluate().length - imagesBefore.evaluate().length;
        print('📈 Image count increase: $imageIncrease');
        
        // Check for network images specifically (uploaded photos)
        final networkImages = find.byWidgetPredicate((widget) {
          return widget is Image && 
                 widget.image is NetworkImage;
        });
        print('🌐 Network images (uploaded): ${networkImages.evaluate().length}');
        
        // Try to find any photo URLs in the widget tree
        await tester.pumpAndSettle(Duration(seconds: 2));
        
        print('\n🎯 === UPLOAD RESULTS ===');
        
        bool uploadWorked = successMessages.evaluate().length > 0 && errorMessages.evaluate().length == 0;
        bool imagesShowing = imagesAfter.evaluate().length > imagesBefore.evaluate().length;
        
        print('📊 RESULTS SUMMARY:');
        print('   • Upload API call successful: ${uploadWorked ? "✅" : "❌"}');
        print('   • Images displaying in UI: ${imagesShowing ? "✅" : "❌"}');
        print('   • Network images found: ${networkImages.evaluate().length > 0 ? "✅" : "❌"}');
        print('   • No errors occurred: ${errorMessages.evaluate().length == 0 ? "✅" : "❌"}');
        
        if (uploadWorked && imagesShowing) {
          print('\n🎉 SUCCESS: Photo upload to dedicated service working!');
          print('📱 Images are now visible in the app');
        } else if (uploadWorked && !imagesShowing) {
          print('\n⚠️ PARTIAL: Upload succeeded but images not displaying');
          print('💡 Possible image URL or display issue');
        } else {
          print('\n❌ ISSUE: Photo upload not working');
          print('🔍 Check photo service connection and response format');
        }
        
        // Try a second upload to verify it's working consistently
        if (uploadWorked && addPhotoElements.evaluate().length > 1) {
          print('\n🔄 === TESTING SECOND UPLOAD ===');
          
          await tester.tap(addPhotoElements.at(1));
          await tester.pumpAndSettle(Duration(seconds: 8));
          
          final finalImages = find.byType(Image);
          final finalNetwork = find.byWidgetPredicate((widget) {
            return widget is Image && widget.image is NetworkImage;
          });
          
          print('🖼️ Final total images: ${finalImages.evaluate().length}');
          print('🌐 Final network images: ${finalNetwork.evaluate().length}');
          
          if (finalNetwork.evaluate().length > networkImages.evaluate().length) {
            print('🎉 Multiple uploads working!');
          }
        }
        
      } else {
        print('❌ No photo upload slots found');
      }
    });
  });
}
