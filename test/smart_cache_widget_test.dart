import 'package:dejtingapp/services/cached_photo_service.dart';
import 'package:dejtingapp/services/photo_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Smart photo cache models', () {
    test('PhotoResponse round-trips through JSON', () {
      final json = {
        'id': 123,
        'userId': 42,
        'originalFileName': 'photo.jpg',
        'displayOrder': 1,
        'isPrimary': true,
        'createdAt': DateTime.utc(2024, 1, 1).toIso8601String(),
        'width': 1080,
        'height': 1920,
        'fileSizeBytes': 512000,
        'moderationStatus': 'approved',
        'qualityScore': 95,
        'urls': {
          'full': 'https://example.com/full.jpg',
          'medium': 'https://example.com/medium.jpg',
          'thumbnail': 'https://example.com/thumb.jpg',
        },
      };

      final response = PhotoResponse.fromJson(json);
      expect(response.id, 123);
      expect(response.urls.thumbnail, contains('thumb'));

      final roundTrip = response.toJson();
      expect(roundTrip['id'], 123);
      expect(roundTrip['urls'], isA<Map<String, dynamic>>());
    });

    test('UserPhotoSummary aggregates cached data correctly', () {
      final summary = UserPhotoSummary.fromJson({
        'userId': 42,
        'totalPhotos': 3,
        'hasPrimaryPhoto': true,
        'primaryPhoto': {
          'id': 1,
          'userId': 42,
          'originalFileName': 'primary.jpg',
          'displayOrder': 0,
          'isPrimary': true,
          'createdAt': DateTime.utc(2024, 2, 1).toIso8601String(),
          'width': 800,
          'height': 600,
          'fileSizeBytes': 200000,
          'moderationStatus': 'approved',
          'qualityScore': 80,
          'urls': {
            'full': 'https://example.com/full.jpg',
            'medium': 'https://example.com/medium.jpg',
            'thumbnail': 'https://example.com/thumb.jpg',
          }
        },
        'photos': [
          {
            'id': 1,
            'userId': 42,
            'originalFileName': 'primary.jpg',
            'displayOrder': 0,
            'isPrimary': true,
            'createdAt': DateTime.utc(2024, 2, 1).toIso8601String(),
            'width': 800,
            'height': 600,
            'fileSizeBytes': 200000,
            'moderationStatus': 'approved',
            'qualityScore': 80,
            'urls': {
              'full': 'https://example.com/full.jpg',
              'medium': 'https://example.com/medium.jpg',
              'thumbnail': 'https://example.com/thumb.jpg',
            }
          }
        ],
        'totalStorageBytes': 1024,
        'remainingPhotoSlots': 4,
        'hasReachedPhotoLimit': false,
      });

      expect(summary.userId, 42);
      expect(summary.photos, hasLength(1));
      expect(summary.hasReachedPhotoLimit, isFalse);
    });

    test('CacheStats formats byte sizes nicely', () {
      final stats = CacheStats(
        totalFiles: 10,
        totalSizeBytes: 5 * 1024 * 1024,
        userOwnedPhotos: 6,
        othersPhotos: 4,
        cacheDirectory: '/tmp/photos',
      );

      expect(stats.formattedSize, contains('MB'));
      expect(stats.totalFiles, 10);
      expect(stats.cacheDirectory, '/tmp/photos');
    });

    test('CachedUserPhotos captures cache flags', () {
      final photo = PhotoResponse(
        id: 10,
        userId: 42,
        originalFileName: 'cached.jpg',
        displayOrder: 0,
        isPrimary: false,
        createdAt: DateTime.utc(2024, 3, 1),
        width: 640,
        height: 480,
        fileSizeBytes: 123456,
        moderationStatus: 'approved',
        qualityScore: 70,
        urls: PhotoUrls(
          full: 'https://example.com/full.jpg',
          medium: 'https://example.com/medium.jpg',
          thumbnail: 'https://example.com/thumb.jpg',
        ),
      );

      final cachedPhoto = CachedPhoto(
        photoResponse: photo,
        localImageBytes: null,
        localPath: '/tmp/photos/cached.jpg',
        isFromCache: true,
      );

      final cachedUserPhotos = CachedUserPhotos(
        userId: 42,
        totalPhotos: 1,
        photos: [cachedPhoto],
        hasReachedPhotoLimit: false,
      );

      expect(cachedUserPhotos.photos.single.isFromCache, isTrue);
      expect(cachedUserPhotos.totalPhotos, 1);
    });
  });
}
