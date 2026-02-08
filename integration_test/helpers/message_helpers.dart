import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'test_config.dart';

/// Modular Messaging API helpers
/// SignalR/WebSocket messaging operations - composable for different chat flows

/// Send a message to a match via REST API fallback
/// Contract: POST /api/messages → 201 with messageId
Future<Map<String, dynamic>> sendMessage(
  TestUser user,
  int recipientUserId, {
  required String text,
}) async {
  final response = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/messages'),
    headers: {
      'Content-Type': 'application/json',
      ...user.authHeaders,
    },
    body: jsonEncode({
      'recipientUserId': recipientUserId,
      'text': text,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('Send message failed: ${response.statusCode} ${response.body}');
  }

  return jsonDecode(response.body);
}

/// Get conversation with a specific user
/// Contract: GET /api/messages/conversation/{userId} → 200 with messages array
Future<List<Map<String, dynamic>>> getConversation(
  TestUser user,
  int otherUserId, {
  int? limit,
  int? offset,
}) async {
  final queryParams = <String, String>{};
  if (limit != null) queryParams['limit'] = limit.toString();
  if (offset != null) queryParams['offset'] = offset.toString();
  
  final uri = Uri.parse(
    '${TestConfig.baseUrl}/api/messages/conversation/$otherUserId'
  ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

  final response = await http.get(
    uri,
    headers: user.authHeaders,
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Get conversation failed: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  return List<Map<String, dynamic>>.from(data['messages'] ?? data);
}

/// Get all conversations for user
/// Contract: GET /api/messages/conversations → 200 with conversations array
Future<List<Map<String, dynamic>>> getConversations(TestUser user) async {
  final response = await http.get(
    Uri.parse('${TestConfig.baseUrl}/api/messages/conversations'),
    headers: user.authHeaders,
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Get conversations failed: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  return List<Map<String, dynamic>>.from(data['conversations'] ?? data);
}

/// Mark message as read
/// Contract: PUT /api/messages/{messageId}/read → 200
Future<void> markMessageRead(TestUser user, int messageId) async {
  final response = await http.put(
    Uri.parse('${TestConfig.baseUrl}/api/messages/$messageId/read'),
    headers: user.authHeaders,
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Mark read failed: ${response.statusCode}');
  }
}

/// Connect to SignalR messaging hub (for real-time testing)
/// This is optional - most tests can use REST API
Future<WebSocketChannel?> connectMessagingHub(TestUser user) async {
  if (!TestConfig.testMessaging) return null;
  
  try {
    final wsUrl = TestConfig.messagingServiceUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    
    final channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl/messagingHub?access_token=${user.accessToken}'),
    );
    
    // Wait for connection
    await channel.ready.timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw Exception('WebSocket connection timeout'),
    );
    
    return channel;
  } catch (e) {
    // WebSocket might not be available - that's OK for HTTP-only tests
    return null;
  }
}

/// Helper: Create match between two users (needed for messaging)
/// Composes existing helpers - demonstrates modularity
Future<void> createMatch(TestUser user1, TestUser user2) async {
  // Import from swipe_helpers would be circular, so inline it
  // In real app, this would be in a shared helper
  final response1 = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/swipes'),
    headers: {
      'Content-Type': 'application/json',
      ...user1.authHeaders,
    },
    body: jsonEncode({
      'targetUserId': user2.profileId ?? user2.userId,
      'isLike': true,
    }),
  ).timeout(TestConfig.apiTimeout);

  final response2 = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/swipes'),
    headers: {
      'Content-Type': 'application/json',
      ...user2.authHeaders,
    },
    body: jsonEncode({
      'targetUserId': user1.profileId ?? user1.userId,
      'isLike': true,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response1.statusCode < 200 || response1.statusCode >= 300) {
    throw Exception('Match creation failed (user1): ${response1.statusCode}');
  }
  if (response2.statusCode < 200 || response2.statusCode >= 300) {
    throw Exception('Match creation failed (user2): ${response2.statusCode}');
  }
}
