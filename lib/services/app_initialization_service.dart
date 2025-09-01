import 'dart:async';
import '../services/api_service.dart';
import '../services/messaging_service_simple.dart';

class AppInitializationService {
  static final AppInitializationService _instance =
      AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  final MessagingService _messagingService = MessagingService();
  bool _isInitialized = false;

  Future<void> initializeApp() async {
    if (_isInitialized) return;

    try {
      // Get current user info
      final userId = AppState().userId;
      final authToken = AppState().authToken;

      if (userId != null && authToken != null) {
        // Initialize messaging service
        await _messagingService.initialize(userId, authToken);

        print('App initialized successfully');
        print('User ID: $userId');
        print('Messaging service connected');
      } else {
        print('User not logged in, skipping messaging initialization');
      }

      _isInitialized = true;
    } catch (e) {
      print('Error initializing app: $e');
      // Don't prevent app from starting if messaging fails
      _isInitialized = true;
    }
  }

  MessagingService get messagingService => _messagingService;
  bool get isInitialized => _isInitialized;

  void reset() {
    _isInitialized = false;
    // Reset messaging service when user logs out
  }
}
