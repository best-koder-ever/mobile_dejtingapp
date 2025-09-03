import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:http/http.dart' as http;
import '../models.dart';

class MessagingService {
  static const String baseUrl = 'http://localhost:5007';
  static const String hubUrl = '$baseUrl/messagingHub';

  HubConnection? _hubConnection;
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();
  final Map<String, List<Message>> _conversationCache = {};

  String? _currentUserId;
  String? _authToken;
  bool _isConnected = false;

  // Streams for UI to listen to
  Stream<Message> get messageStream => _messageController.stream;
  Stream<String> get connectionStatusStream =>
      _connectionStatusController.stream;
  bool get isConnected => _isConnected;

  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  /// Initialize the messaging service with user credentials
  Future<void> initialize(String userId, String authToken) async {
    _currentUserId = userId;
    _authToken = authToken;
    await _connectToHub();
  }

  /// Create an empty message for error handling
  Message _createEmptyMessage() => Message(
        id: '',
        senderId: '',
        receiverId: '',
        content: '',
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.text,
      );

  /// Connect to SignalR hub
  Future<void> _connectToHub() async {
    try {
      _connectionStatusController.add('Connecting...');

      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async => _authToken ?? '',
                transport: HttpTransportType.WebSockets,
                skipNegotiation: false,
                logMessageContent: kDebugMode,
              ))
          .build();

      // Set up event handlers
      _hubConnection!.on('ReceiveMessage', _onMessageReceived);
      _hubConnection!.on('MessageSent', _onMessageSent);
      _hubConnection!.on('MessageRead', _onMessageRead);
      _hubConnection!.on('Error', _onError);

      // Connection state handlers
      _hubConnection!.onclose(({Exception? error}) {
        _isConnected = false;
        _connectionStatusController.add('Disconnected');
        if (kDebugMode) {
          print('SignalR connection closed: $error');
        }
        // Auto-reconnect after 5 seconds
        Timer(const Duration(seconds: 5), _reconnect);
      });

      _hubConnection!.onreconnecting(({Exception? error}) {
        _connectionStatusController.add('Reconnecting...');
        if (kDebugMode) {
          print('SignalR reconnecting: $error');
        }
      });

      _hubConnection!.onreconnected(({String? connectionId}) {
        _isConnected = true;
        _connectionStatusController.add('Connected');
        if (kDebugMode) {
          print('SignalR reconnected with ID: $connectionId');
        }
      });

      // Start the connection
      await _hubConnection!.start();
      _isConnected = true;
      _connectionStatusController.add('Connected');

      if (kDebugMode) {
        print('✅ Connected to messaging hub');
      }
    } catch (e) {
      _isConnected = false;
      _connectionStatusController.add('Connection failed');
      if (kDebugMode) {
        print('❌ Failed to connect to messaging hub: $e');
      }
      // Retry connection after 10 seconds
      Timer(const Duration(seconds: 10), _reconnect);
    }
  }

  /// Reconnect to the hub
  Future<void> _reconnect() async {
    if (!_isConnected && _currentUserId != null && _authToken != null) {
      await _connectToHub();
    }
  }

  /// Handle incoming messages
  void _onMessageReceived(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty) return;

    try {
      final messageData = parameters[0] as Map<String, dynamic>;
      final message = Message.fromJson(messageData);

      // Add to cache
      final conversationId =
          _getConversationId(_currentUserId!, message.senderId);
      _conversationCache[conversationId] ??= [];
      _conversationCache[conversationId]!.add(message);

      // Notify listeners
      _messageController.add(message);

      if (kDebugMode) {
        print('📨 Received message: ${message.content}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing received message: $e');
      }
    }
  }

  /// Handle message sent confirmation
  void _onMessageSent(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty) return;

    try {
      final messageData = parameters[0] as Map<String, dynamic>;
      final message = Message.fromJson(messageData);

      // Update cache with confirmed message
      final conversationId =
          _getConversationId(_currentUserId!, message.receiverId);
      _conversationCache[conversationId] ??= [];

      // Update or add the message
      final existingIndex = _conversationCache[conversationId]!.indexWhere(
          (m) =>
              m.content == message.content && m.senderId == message.senderId);

      if (existingIndex != -1) {
        _conversationCache[conversationId]![existingIndex] = message;
      } else {
        _conversationCache[conversationId]!.add(message);
      }

      if (kDebugMode) {
        print('✅ Message sent confirmed: ${message.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing sent message: $e');
      }
    }
  }

  /// Handle message read confirmation
  void _onMessageRead(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty) return;

    try {
      final messageId = parameters[0] as int;

      // Update message read status in cache
      for (final conversation in _conversationCache.values) {
        final message = conversation.firstWhere(
          (m) => m.id == messageId.toString(),
          orElse: () => _createEmptyMessage(),
        );
        if (message.id.isNotEmpty) {
          // Create a new message with updated read status
          final updatedMessage = message.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          final index = conversation.indexOf(message);
          conversation[index] = updatedMessage;
          break;
        }
      }

      if (kDebugMode) {
        print('✅ Message marked as read: $messageId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing read receipt: $e');
      }
    }
  }

  /// Handle errors from the hub
  void _onError(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty) return;

    final error = parameters[0] as String;
    _connectionStatusController.add('Error: $error');

    if (kDebugMode) {
      print('❌ SignalR error: $error');
    }
  }

  /// Send a message
  Future<bool> sendMessage(String receiverId, String content,
      {MessageType type = MessageType.text}) async {
    if (!_isConnected || _hubConnection == null) {
      if (kDebugMode) {
        print('❌ Cannot send message: Not connected to hub');
      }
      return false;
    }

    try {
      // Optimistically add message to cache
      final tempMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _currentUserId!,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        type: type,
      );

      final conversationId = _getConversationId(_currentUserId!, receiverId);
      _conversationCache[conversationId] ??= [];
      _conversationCache[conversationId]!.add(tempMessage);

      // Send via SignalR
      await _hubConnection!
          .invoke('SendMessage', args: [receiverId, content, type.index]);

      if (kDebugMode) {
        print('📤 Sent message: $content');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send message: $e');
      }
      return false;
    }
  }

  /// Get conversation history
  Future<List<Message>> getConversation(String otherUserId,
      {int page = 1, int pageSize = 50}) async {
    final conversationId = _getConversationId(_currentUserId!, otherUserId);

    // Return cached messages if available
    if (_conversationCache.containsKey(conversationId)) {
      return List.from(_conversationCache[conversationId]!.reversed);
    }

    // Fetch from API
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/messages/conversation/$otherUserId?page=$page&pageSize=$pageSize'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        final messages =
            messagesJson.map((json) => Message.fromJson(json)).toList();

        // Cache the messages
        _conversationCache[conversationId] = messages.reversed.toList();

        return messages;
      } else {
        if (kDebugMode) {
          print('❌ Failed to load conversation: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading conversation: $e');
      }
      return [];
    }
  }

  /// Get all conversations
  Future<List<ConversationSummary>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/conversations'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> conversationsJson = json.decode(response.body);
        return conversationsJson
            .map((json) => ConversationSummary.fromJson(json))
            .toList();
      } else {
        if (kDebugMode) {
          print('❌ Failed to load conversations: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading conversations: $e');
      }
      return [];
    }
  }

  /// Mark message as read
  Future<void> markAsRead(String messageId) async {
    try {
      if (_isConnected && _hubConnection != null) {
        await _hubConnection!
            .invoke('MarkAsRead', args: [int.parse(messageId)]);
      }

      // Also call REST API as backup
      await http.post(
        Uri.parse('$baseUrl/api/messages/$messageId/read'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error marking message as read: $e');
      }
    }
  }

  /// Join a conversation room
  Future<void> joinConversation(String otherUserId) async {
    if (_isConnected && _hubConnection != null) {
      try {
        final conversationId = _getConversationId(_currentUserId!, otherUserId);
        await _hubConnection!
            .invoke('JoinConversation', args: [conversationId]);

        if (kDebugMode) {
          print('👥 Joined conversation: $conversationId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error joining conversation: $e');
        }
      }
    }
  }

  /// Leave a conversation room
  Future<void> leaveConversation(String otherUserId) async {
    if (_isConnected && _hubConnection != null) {
      try {
        final conversationId = _getConversationId(_currentUserId!, otherUserId);
        await _hubConnection!
            .invoke('LeaveConversation', args: [conversationId]);

        if (kDebugMode) {
          print('👋 Left conversation: $conversationId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error leaving conversation: $e');
        }
      }
    }
  }

  /// Get cached messages for a conversation
  List<Message> getCachedMessages(String otherUserId) {
    final conversationId = _getConversationId(_currentUserId!, otherUserId);
    return _conversationCache[conversationId] ?? [];
  }

  /// Generate conversation ID
  String _getConversationId(String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return '${users[0]}_${users[1]}';
  }

  /// Disconnect from the hub
  Future<void> disconnect() async {
    try {
      await _hubConnection?.stop();
      _isConnected = false;
      _connectionStatusController.add('Disconnected');

      if (kDebugMode) {
        print('👋 Disconnected from messaging hub');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error disconnecting: $e');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _messageController.close();
    _connectionStatusController.close();
    _hubConnection?.stop();
  }
}

/// Conversation summary model
class ConversationSummary {
  final String conversationId;
  final Message lastMessage;
  final int unreadCount;
  final String otherUserId;

  ConversationSummary({
    required this.conversationId,
    required this.lastMessage,
    required this.unreadCount,
    required this.otherUserId,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) =>
      ConversationSummary(
        conversationId: json['conversationId'] ?? '',
        lastMessage: Message.fromJson(json['lastMessage'] ?? {}),
        unreadCount: json['unreadCount'] ?? 0,
        otherUserId: json['otherUserId'] ?? '',
      );
}
