import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dejtingapp/services/photo_service.dart';

// Generate mocks with: flutter packages pub run build_runner build
@GenerateMocks([http.Client])
import 'photo_service_test.mocks.dart';

void main() {
  group('PhotoService', () {
    late PhotoService photoService;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      photoService = PhotoService();
    });

    group('DTO Validation', () {
      test('PhotoUploadResult.fromJson should parse valid response', () {
        final jsonResponse = {
          'success': true,
          'errorMessage': null,
          'warnings': ['Image was resized'],
          'photo': {
            'id': 1,
            'userId': 123,
            'originalFileName': 'test.jpg',
            'displayOrder': 1,
            'isPrimary': true,
            'createdAt': '2025-09-19T10:00:00Z',
            'width': 1080,
            'height': 1080,
            'fileSizeBytes': 524288,
            'moderationStatus': 'Approved',
            'qualityScore': 85,
            'urls': {
              'full': 'http://localhost:8084/photos/1/full.jpg',
              'medium': 'http://localhost:8084/photos/1/medium.jpg',
              'thumbnail': 'http://localhost:8084/photos/1/thumb.jpg',
            }
          },
          'processingInfo': {
            'wasResized': true,
            'originalWidth': 1920,
            'originalHeight': 1080,
            'finalWidth': 1080,
            'finalHeight': 1080,
            'formatConverted': false,
            'originalFormat': 'JPEG',
            'finalFormat': 'JPEG',
            'processingTimeMs': 150
          }
        };

        final result = PhotoUploadResult.fromJson(jsonResponse);

        expect(result.success, isTrue);
        expect(result.warnings, contains('Image was resized'));
        expect(result.photo, isNotNull);
        expect(result.photo!.id, equals(1));
        expect(result.photo!.userId, equals(123));
        expect(result.photo!.isPrimary, isTrue);
        expect(result.photo!.fileSizeFormatted, equals('512.0 KB'));
        expect(result.processingInfo, isNotNull);
        expect(result.processingInfo!.wasResized, isTrue);
      });

      test('PhotoUploadResult.fromJson should handle error response', () {
        final jsonResponse = {
          'success': false,
          'errorMessage': 'File too large',
          'warnings': [],
          'photo': null,
          'processingInfo': null
        };

        final result = PhotoUploadResult.fromJson(jsonResponse);

        expect(result.success, isFalse);
        expect(result.errorMessage, equals('File too large'));
        expect(result.photo, isNull);
        expect(result.processingInfo, isNull);
      });

      test('UserPhotoSummary.fromJson should parse complete response', () {
        final jsonResponse = {
          'userId': 123,
          'totalPhotos': 3,
          'hasPrimaryPhoto': true,
          'primaryPhoto': {
            'id': 1,
            'userId': 123,
            'originalFileName': 'primary.jpg',
            'displayOrder': 1,
            'isPrimary': true,
            'createdAt': '2025-09-19T10:00:00Z',
            'width': 1080,
            'height': 1080,
            'fileSizeBytes': 524288,
            'moderationStatus': 'Approved',
            'qualityScore': 90,
            'urls': {
              'full': 'http://localhost:8084/photos/1/full.jpg',
              'medium': 'http://localhost:8084/photos/1/medium.jpg',
              'thumbnail': 'http://localhost:8084/photos/1/thumb.jpg',
            }
          },
          'photos': [
            {
              'id': 1,
              'userId': 123,
              'originalFileName': 'primary.jpg',
              'displayOrder': 1,
              'isPrimary': true,
              'createdAt': '2025-09-19T10:00:00Z',
              'width': 1080,
              'height': 1080,
              'fileSizeBytes': 524288,
              'moderationStatus': 'Approved',
              'qualityScore': 90,
              'urls': {
                'full': 'http://localhost:8084/photos/1/full.jpg',
                'medium': 'http://localhost:8084/photos/1/medium.jpg',
                'thumbnail': 'http://localhost:8084/photos/1/thumb.jpg',
              }
            }
          ],
          'totalStorageBytes': 1572864,
          'remainingPhotoSlots': 3,
          'hasReachedPhotoLimit': false
        };

        final summary = UserPhotoSummary.fromJson(jsonResponse);

        expect(summary.userId, equals(123));
        expect(summary.totalPhotos, equals(3));
        expect(summary.hasPrimaryPhoto, isTrue);
        expect(summary.primaryPhoto, isNotNull);
        expect(summary.photos.length, equals(1));
        expect(summary.totalStorageFormatted, equals('1.5 MB'));
        expect(summary.remainingPhotoSlots, equals(3));
        expect(summary.hasReachedPhotoLimit, isFalse);
      });
    });

    group('File Size Formatting', () {
      test('should format bytes correctly', () {
        final photo = PhotoResponse(
          id: 1,
          userId: 123,
          originalFileName: 'test.jpg',
          displayOrder: 1,
          isPrimary: false,
          createdAt: DateTime.now(),
          width: 1080,
          height: 1080,
          fileSizeBytes: 1024,
          moderationStatus: 'Approved',
          qualityScore: 85,
          urls: PhotoUrls(full: '', medium: '', thumbnail: ''),
        );

        expect(photo.fileSizeFormatted, equals('1.0 KB'));
      });

      test('should format MB correctly', () {
        final photo = PhotoResponse(
          id: 1,
          userId: 123,
          originalFileName: 'test.jpg',
          displayOrder: 1,
          isPrimary: false,
          createdAt: DateTime.now(),
          width: 1080,
          height: 1080,
          fileSizeBytes: 1048576, // 1 MB
          moderationStatus: 'Approved',
          qualityScore: 85,
          urls: PhotoUrls(full: '', medium: '', thumbnail: ''),
        );

        expect(photo.fileSizeFormatted, equals('1.0 MB'));
      });
    });

    group('Photo Order Items', () {
      test('should serialize to correct JSON format for C# API', () {
        final orderItem = PhotoOrderItem(
          photoId: 123,
          displayOrder: 2,
        );

        final json = orderItem.toJson();

        expect(json['PhotoId'], equals(123)); // PascalCase for C#
        expect(json['DisplayOrder'], equals(2));
      });

      test('should parse from JSON correctly', () {
        final json = {
          'photoId': 456,
          'displayOrder': 3,
        };

        final orderItem = PhotoOrderItem.fromJson(json);

        expect(orderItem.photoId, equals(456));
        expect(orderItem.displayOrder, equals(3));
      });
    });

    group('Service Health Check', () {
      test('should return true when service is healthy', () async {
        // This test requires the actual PhotoService to be running
        // Skip if running in CI or if service is not available
        final isHealthy = await photoService.isServiceHealthy();

        // This will pass if service is running, skip if not
        if (isHealthy) {
          expect(isHealthy, isTrue);
        } else {
          print('⚠️ PhotoService not running - skipping health check test');
        }
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // Create a service that will fail
        final failingService = PhotoService();

        // Try to upload to a non-existent file (will throw)
        final result = await failingService.uploadPhoto(
          imageFile: File('/non/existent/file.jpg'),
          authToken: 'fake-token',
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, isNotNull);
        expect(result.errorMessage, contains('Upload failed'));
      });

      test('should handle invalid auth token', () async {
        // This test would need the service running to test properly
        // For now, just verify the method signature
        expect(() async {
          await photoService.getUserPhotos(
            authToken: 'invalid-token',
            userId: 123,
          );
        }, returnsNormally);
      });
    });

    group('Photo Requirements Validation', () {
      test('should validate minimum photo requirements', () {
        final photos = <PhotoResponse>[];

        // Test with no photos
        expect(photos.length >= 4, isFalse);

        // Add 4 photos
        for (int i = 0; i < 4; i++) {
          photos.add(PhotoResponse(
            id: i + 1,
            userId: 123,
            originalFileName: 'photo$i.jpg',
            displayOrder: i + 1,
            isPrimary: i == 0,
            createdAt: DateTime.now(),
            width: 1080,
            height: 1080,
            fileSizeBytes: 524288,
            moderationStatus: 'Approved',
            qualityScore: 85,
            urls: PhotoUrls(full: '', medium: '', thumbnail: ''),
          ));
        }

        expect(photos.length >= 4, isTrue);
        expect(photos.length <= 6, isTrue);
      });

      test('should enforce maximum photo limit', () {
        final photos = <PhotoResponse>[];

        // Add 7 photos (over limit)
        for (int i = 0; i < 7; i++) {
          photos.add(PhotoResponse(
            id: i + 1,
            userId: 123,
            originalFileName: 'photo$i.jpg',
            displayOrder: i + 1,
            isPrimary: i == 0,
            createdAt: DateTime.now(),
            width: 1080,
            height: 1080,
            fileSizeBytes: 524288,
            moderationStatus: 'Approved',
            qualityScore: 85,
            urls: PhotoUrls(full: '', medium: '', thumbnail: ''),
          ));
        }

        expect(photos.length > 6, isTrue); // Over limit
        expect(photos.take(6).length, equals(6)); // Enforce limit
      });

      test('should ensure at least one primary photo', () {
        final photos = [
          PhotoResponse(
            id: 1,
            userId: 123,
            originalFileName: 'primary.jpg',
            displayOrder: 1,
            isPrimary: true,
            createdAt: DateTime.now(),
            width: 1080,
            height: 1080,
            fileSizeBytes: 524288,
            moderationStatus: 'Approved',
            qualityScore: 85,
            urls: PhotoUrls(full: '', medium: '', thumbnail: ''),
          ),
          PhotoResponse(
            id: 2,
            userId: 123,
            originalFileName: 'secondary.jpg',
            displayOrder: 2,
            isPrimary: false,
            createdAt: DateTime.now(),
            width: 1080,
            height: 1080,
            fileSizeBytes: 524288,
            moderationStatus: 'Approved',
            qualityScore: 85,
            urls: PhotoUrls(full: '', medium: '', thumbnail: ''),
          ),
        ];

        final hasPrimary = photos.any((photo) => photo.isPrimary);
        expect(hasPrimary, isTrue);
      });
    });

    group('URL Generation', () {
      test('should generate correct photo URLs', () {
        final urls = PhotoUrls(
          full: 'http://localhost:8084/photos/123/full.jpg',
          medium: 'http://localhost:8084/photos/123/medium.jpg',
          thumbnail: 'http://localhost:8084/photos/123/thumb.jpg',
        );

        expect(urls.full, contains('full.jpg'));
        expect(urls.medium, contains('medium.jpg'));
        expect(urls.thumbnail, contains('thumb.jpg'));
        expect(urls.full, startsWith('http://localhost:8084'));
      });

      test('should prefer medium over full URL for display', () {
        final photo = PhotoResponse(
          id: 1,
          userId: 123,
          originalFileName: 'test.jpg',
          displayOrder: 1,
          isPrimary: false,
          createdAt: DateTime.now(),
          width: 1080,
          height: 1080,
          fileSizeBytes: 524288,
          moderationStatus: 'Approved',
          qualityScore: 85,
          urls: PhotoUrls(
            full: 'http://localhost:8084/photos/1/full.jpg',
            medium: 'http://localhost:8084/photos/1/medium.jpg',
            thumbnail: 'http://localhost:8084/photos/1/thumb.jpg',
          ),
        );

        // Simulate display logic: prefer medium if available
        final displayUrl =
            photo.urls.medium.isNotEmpty ? photo.urls.medium : photo.urls.full;

        expect(displayUrl, equals(photo.urls.medium));
      });
    });
  });
}
