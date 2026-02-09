import 'models.dart';
import 'services/api_service.dart' as session;
import 'services/auth_session_manager.dart';
import 'services/swipe_service.dart';

class AuthApiService {
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final result = await AuthSessionManager.login(
      username: email,
      password: password,
    );

    if (!result.success) {
      throw Exception(result.message ?? 'Login failed');
    }

    final token = await session.AppState().getOrRefreshAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unable to retrieve access token after login.');
    }

    return token;
  }

  Future<void> logout() async {
    await session.AppState().logout();
  }

  Future<bool> isLoggedIn() async {
    await session.AppState().initialize();
    return session.AppState().userId != null;
  }

  /// Register opens the Keycloak registration portal — handled externally.
  /// This is a no-op placeholder; see screens/auth_screens.dart for actual flow.
  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    // Registration is handled via Keycloak portal (URL_launcher)
    // This method exists for API compatibility only
    throw UnimplementedError(
      'Self-registration is handled via Keycloak portal. '
      'Use screens/auth_screens.dart RegisterScreen instead.',
    );
  }
}

class UserApiService {
  /// Create a user profile. Accepts a UserProfile or Map<String, dynamic>.
  Future<UserProfile> createProfile(dynamic payload) async {
    final Map<String, dynamic> data =
        payload is UserProfile ? payload.toJson() : payload as Map<String, dynamic>;
    final userId = session.AppState().userId;
    if (userId == null) throw Exception('Not authenticated');
    final success = await session.UserService.updateUserProfile(userId, data);
    if (!success) throw Exception('Failed to create profile.');
    final profile = await session.UserService.getUserProfile(userId);
    if (profile == null) throw Exception('Failed to retrieve created profile.');
    return UserProfile.fromJson(profile);
  }

  /// Get the current user's profile.
  Future<UserProfile?> getMyProfile() async {
    final userId = session.AppState().userId;
    if (userId == null) return null;
    final data = await session.UserService.getUserProfile(userId);
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  /// Update a user profile. Accepts a UserProfile or Map<String, dynamic>.
  Future<UserProfile> updateProfile(dynamic payload) async {
    final Map<String, dynamic> data =
        payload is UserProfile ? payload.toJson() : payload as Map<String, dynamic>;
    final userId = session.AppState().userId;
    if (userId == null) throw Exception('Not authenticated');
    final success = await session.UserService.updateUserProfile(userId, data);
    if (!success) throw Exception('Failed to update profile.');
    final profile = await session.UserService.getUserProfile(userId);
    if (profile == null) throw Exception('Failed to retrieve updated profile.');
    return UserProfile.fromJson(profile);
  }

  /// Get current user ID from AppState.
  Future<String?> getCurrentUserId() async {
    await session.AppState().initialize();
    return session.AppState().userId;
  }

  /// Get a valid auth token (refreshes if needed).
  Future<String?> getAuthToken() async {
    return await session.AppState().getOrRefreshAuthToken();
  }

  /// Delete a photo by URL (delegates to PhotoService).
  Future<bool> deletePhoto(String photoUrl) async {
    return await session.PhotoService.deletePhoto(photoUrl);
  }
}

class MatchmakingApiService {
  /// Get candidate profiles for swiping.
  Future<List<MatchCandidate>> getCandidates({
    int page = 1,
    int pageSize = 20,
  }) async {
    final userId = session.AppState().userId;
    if (userId == null) return [];
    final rawList = await session.MatchmakingService.getProfiles(userId);
    return rawList.map((m) => MatchCandidate.fromJson(m)).toList();
  }

  /// Enhanced swipe with automatic retry and idempotency.
  Future<Map<String, dynamic>?> swipe({
    required String targetUserId,
    required bool isLike,
    String? idempotencyKey,
  }) async {
    return await SwipeService.swipe(
      targetUserId: targetUserId,
      isLike: isLike,
      idempotencyKey: idempotencyKey,
    );
  }

  /// Get the current user's matches.
  Future<List<MatchSummary>> getMatches() async {
    final userId = session.AppState().userId;
    if (userId == null) return [];
    final rawList = await session.MatchmakingService.getMatches(userId);
    return rawList.map((m) => MatchSummary.fromJson(m)).toList();
  }
}

final authApi = AuthApiService();
final userApi = UserApiService();
final matchmakingApi = MatchmakingApiService();
