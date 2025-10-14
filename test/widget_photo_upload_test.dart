import 'package:dejtingapp/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile model', () {
    test('fromJson handles summary DTO structure', () {
      final json = {
        'Id': 101,
        'UserId': 202,
        'Name': 'Alex Johnson',
        'Age': 29,
        'Bio': 'Traveler and foodie',
        'City': 'Stockholm',
        'PrimaryPhotoUrl': 'https://cdn.example.com/photos/alex.jpg',
        'PhotoUrls': [
          'https://cdn.example.com/photos/alex.jpg',
          'https://cdn.example.com/photos/alex2.jpg',
        ],
        'Interests': ['hiking', 'coffee'],
        'Languages': ['English', 'Swedish'],
        'IsOnline': true,
        'IsPremium': false,
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.userId, '202');
      expect(profile.fullName, 'Alex Johnson');
      expect(profile.photoUrls, hasLength(2));
      expect(profile.city, 'Stockholm');
      expect(profile.isOnline, isTrue);
      expect(profile.languages, contains('Swedish'));
    });

    test('fromJson derives fields when only summary data is present', () {
      final json = {
        'id': 55,
        'name': 'Jamie',
        'age': 31,
        'isVerified': true,
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.firstName, 'Jamie');
      expect(profile.lastName, isEmpty);
      expect(profile.isVerified, isTrue);
      expect(profile.photoUrls, isEmpty);
    });

    test('toJson preserves key properties', () {
      final now = DateTime.utc(1995, 7, 20);
      final profile = UserProfile(
        id: 'abc',
        userId: '999',
        firstName: 'Taylor',
        lastName: 'Smith',
        dateOfBirth: now,
        bio: 'Runner',
        city: 'Gothenburg',
        occupation: 'Engineer',
        interests: ['running'],
        primaryPhotoUrl: 'https://cdn.example.com/photos/taylor.jpg',
        photoUrls: const ['https://cdn.example.com/photos/taylor.jpg'],
        isVerified: true,
        isPremium: true,
        languages: const ['English'],
      );

      final json = profile.toJson();

      expect(json['userId'], '999');
      expect(json['firstName'], 'Taylor');
      expect(json['lastName'], 'Smith');
      expect(json['isVerified'], isTrue);
      expect(json['photoUrls'],
          contains('https://cdn.example.com/photos/taylor.jpg'));
    });
  });

  group('SearchFilters serialization', () {
    test('serializes only non-null values', () {
      const filters = SearchFilters(
        minAge: 25,
        maxAge: 35,
        city: 'Stockholm',
        interests: ['music'],
        education: 'Masters',
      );

      final json = filters.toJson();

      expect(json['minAge'], 25);
      expect(json['maxAge'], 35);
      expect(json['location'], 'Stockholm');
      expect(json['interests'], contains('music'));
      expect(json['pageSize'], greaterThan(0));
    });
  });
}
