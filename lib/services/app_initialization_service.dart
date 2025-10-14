import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import '../services/messaging_service_simple.dart';

class AppInitializationService {
  static final AppInitializationService _instance =
      AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  final MessagingService _messagingService = MessagingService();
  bool _isInitialized = false;
  bool _warnedMessagingUnavailable = false;

  Future<void> initializeApp() async {
    if (_isInitialized) return;

    try {
      // Get current user info
      final userId = AppState().userId;
      final authToken = AppState().authToken;

      if (userId != null && authToken != null) {
        final messagingAvailable = await _isMessagingServiceAvailable();
        if (messagingAvailable) {
          await _messagingService.initialize(userId, authToken);

          print('App initialized successfully');
          print('User ID: $userId');
          print('Messaging service connected');
        } else {
          if (!_warnedMessagingUnavailable) {
            print('⚠️ Messaging service unavailable. Skipping initialization.');
            _warnedMessagingUnavailable = true;
          }
        }
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
    _warnedMessagingUnavailable = false;
  }

  Future<bool> _isMessagingServiceAvailable() async {
    final baseUrl = MessagingService.baseUrl;

    if (baseUrl.isEmpty) {
      return false;
    }

    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      if (kDebugMode) {
        print('Messaging health check failed: $e');
      }
      return false;
    }
  }
}
