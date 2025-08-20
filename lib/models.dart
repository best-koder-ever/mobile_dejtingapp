// Data models for the Flutter app that match the enhanced backend

class User {
  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profilePicture;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
    };
  }
}

class UserProfile {
  final String? id;
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String? bio;
  final String? city;
  final String? occupation;
  final List<String> interests;
  final int? height;
  final String? education;
  final double? latitude;
  final double? longitude;
  final String? primaryPhotoUrl;
  final List<String> photoUrls;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastActiveAt;
  final bool isActive;
  final String? lifestyle;
  final String? relationshipGoals;
  final bool isPremium;
  final String? gender;
  final String? preferences;
  final String? drinking;
  final String? smoking;
  final String? workout;
  final List<String> languages;

  UserProfile({
    this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.bio,
    this.city,
    this.occupation,
    this.interests = const [],
    this.height,
    this.education,
    this.latitude,
    this.longitude,
    this.primaryPhotoUrl,
    this.photoUrls = const [],
    this.isVerified = false,
    this.isOnline = false,
    this.lastActiveAt,
    this.isActive = true,
    this.lifestyle,
    this.relationshipGoals,
    this.isPremium = false,
    this.gender,
    this.preferences,
    this.drinking,
    this.smoking,
    this.workout,
    this.languages = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString(),
      userId: json['userId'].toString(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      bio: json['bio'],
      city: json['city'],
      occupation: json['occupation'],
      interests:
          json['interests'] != null ? List<String>.from(json['interests']) : [],
      height: json['height'],
      education: json['education'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      primaryPhotoUrl: json['primaryPhotoUrl'],
      photoUrls:
          json['photoUrls'] != null ? List<String>.from(json['photoUrls']) : [],
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastActiveAt:
          json['lastActiveAt'] != null
              ? DateTime.parse(json['lastActiveAt'])
              : null,
      isActive: json['isActive'] ?? true,
      lifestyle: json['lifestyle'],
      relationshipGoals: json['relationshipGoals'],
      isPremium: json['isPremium'] ?? false,
      gender: json['gender'],
      preferences: json['preferences'],
      drinking: json['drinking'],
      smoking: json['smoking'],
      workout: json['workout'],
      languages:
          json['languages'] != null ? List<String>.from(json['languages']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'bio': bio,
      'city': city,
      'occupation': occupation,
      'interests': interests,
      'height': height,
      'education': education,
      'latitude': latitude,
      'longitude': longitude,
      'primaryPhotoUrl': primaryPhotoUrl,
      'photoUrls': photoUrls,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isActive': isActive,
      'lifestyle': lifestyle,
      'relationshipGoals': relationshipGoals,
      'isPremium': isPremium,
      'gender': gender,
      'preferences': preferences,
      'drinking': drinking,
      'smoking': smoking,
      'workout': workout,
      'languages': languages,
    };
  }

  int get age {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      return age - 1;
    }
    return age;
  }

  String get fullName => '$firstName $lastName';
}

class SwipeResponse {
  final bool isMatch;
  final String? matchId;
  final String message;

  SwipeResponse({required this.isMatch, this.matchId, required this.message});

  factory SwipeResponse.fromJson(Map<String, dynamic> json) {
    return SwipeResponse(
      isMatch: json['isMatch'] ?? false,
      matchId: json['matchId'],
      message: json['message'] ?? '',
    );
  }
}

class Match {
  final String id;
  final String userId1;
  final String userId2;
  final DateTime matchedAt;
  final bool isActive;
  final UserProfile? otherUserProfile;

  Match({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.matchedAt,
    this.isActive = true,
    this.otherUserProfile,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'].toString(),
      userId1: json['userId1'].toString(),
      userId2: json['userId2'].toString(),
      matchedAt: DateTime.parse(json['matchedAt']),
      isActive: json['isActive'] ?? true,
      otherUserProfile:
          json['otherUserProfile'] != null
              ? UserProfile.fromJson(json['otherUserProfile'])
              : null,
    );
  }
}

class CompatibilityScore {
  final double overallScore;
  final double locationScore;
  final double ageScore;
  final double interestsScore;
  final double educationScore;
  final double lifestyleScore;

  CompatibilityScore({
    required this.overallScore,
    required this.locationScore,
    required this.ageScore,
    required this.interestsScore,
    required this.educationScore,
    required this.lifestyleScore,
  });

  factory CompatibilityScore.fromJson(Map<String, dynamic> json) {
    return CompatibilityScore(
      overallScore: (json['overallScore'] ?? 0).toDouble(),
      locationScore: (json['locationScore'] ?? 0).toDouble(),
      ageScore: (json['ageScore'] ?? 0).toDouble(),
      interestsScore: (json['interestsScore'] ?? 0).toDouble(),
      educationScore: (json['educationScore'] ?? 0).toDouble(),
      lifestyleScore: (json['lifestyleScore'] ?? 0).toDouble(),
    );
  }
}

class SearchFilters {
  final int? minAge;
  final int? maxAge;
  final String? city;
  final double? maxDistance;
  final List<String>? interests;
  final String? education;
  final int page;
  final int pageSize;

  SearchFilters({
    this.minAge,
    this.maxAge,
    this.city,
    this.maxDistance,
    this.interests,
    this.education,
    this.page = 1,
    this.pageSize = 10,
  });

  Map<String, dynamic> toQueryParams() {
    Map<String, dynamic> params = {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (minAge != null) params['minAge'] = minAge.toString();
    if (maxAge != null) params['maxAge'] = maxAge.toString();
    if (city != null) params['city'] = city!;
    if (maxDistance != null) params['maxDistance'] = maxDistance.toString();
    if (education != null) params['education'] = education!;

    return params;
  }
}
