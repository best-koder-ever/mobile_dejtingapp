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
}

class UserApiService {
  Future<MemberProfile> createProfile(Map<String, dynamic> payload) async {
    final profile = await session.UserService.updateProfile(payload);
    if (profile == null) {
      throw Exception('Failed to create profile.');
    }
    return profile;
  }

  Future<MemberProfile?> getMyProfile() async {
    return await session.UserService.getProfile();
  }

  Future<MemberProfile> updateProfile(Map<String, dynamic> payload) async {
    final profile = await session.UserService.updateProfile(payload);
    if (profile == null) {
      throw Exception('Failed to update profile.');
    }
    return profile;
  }

  Future<String?> getCurrentUserId() async {
    await session.AppState().initialize();
    return session.AppState().userId;
  }
}

class MatchmakingApiService {
  Future<List<MatchCandidate>> getCandidates({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await session.MatchmakingService.getCandidates(
      page: page,
      pageSize: pageSize,
    );
  }

  /// Enhanced swipe with automatic retry and idempotency
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

  Future<List<MatchSummary>> getMatches() async {
    return await session.MatchmakingService.getMatches();
  }
}

final authApi = AuthApiService();
final userApi = UserApiService();
final matchmakingApi = MatchmakingApiService();
