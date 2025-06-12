import 'package:flutter/material.dart';
import 'swipe_service_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'backend_url.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final SwipeServiceApi api = SwipeServiceApi(
    baseUrl: getBackendBaseUrl(port: 8080),
  ); // Use 10.0.2.2 for Android emulator
  final _storage = const FlutterSecureStorage();
  String? _swipeResult;
  int? userId;
  int? targetUserId;
  bool _loading = true;
  List<dynamic> _usersToSwipe = [];
  int _currentIndex = 0;
  Map<String, dynamic>? _currentTargetUser;

  @override
  void initState() {
    super.initState();
    _initUserIds();
  }

  Future<void> _initUserIds() async {
    // Get email from secure storage (set at login)
    String? email = await _storage.read(key: 'email');
    if (email == null) {
      setState(() {
        _swipeResult = 'Error: Not logged in.';
        _loading = false;
      });
      return;
    }
    // Fetch userId for this email from backend
    final userResp = await http.get(
      Uri.parse(getBackendBaseUrl(port: 8081) + '/api/users/by-email/$email'),
    );
    if (userResp.statusCode != 200) {
      setState(() {
        _swipeResult = 'Error: Could not fetch userId for $email';
        _loading = false;
      });
      return;
    }
    final userJson = jsonDecode(userResp.body);
    final int myUserId =
        userJson['id'] is int
            ? userJson['id']
            : int.tryParse(userJson['id'].toString()) ?? 0;
    // Fetch a target user (any user except self)
    final allUsersResp = await http.get(
      Uri.parse(getBackendBaseUrl(port: 8081) + '/api/users'),
    );
    if (allUsersResp.statusCode != 200) {
      setState(() {
        _swipeResult = 'Error: Could not fetch users list.';
        _loading = false;
      });
      return;
    }
    final usersList = jsonDecode(allUsersResp.body) as List;
    final filteredUsers = usersList.where((u) => u['id'] != myUserId).toList();
    setState(() {
      userId = myUserId;
      _usersToSwipe = filteredUsers;
      _currentIndex = 0;
      _currentTargetUser = _usersToSwipe.isNotEmpty ? _usersToSwipe[0] : null;
      targetUserId =
          _currentTargetUser != null
              ? (_currentTargetUser!['id'] is int
                  ? _currentTargetUser!['id']
                  : int.tryParse(_currentTargetUser!['id'].toString()) ?? 0)
              : null;
      _loading = false;
      if (targetUserId == null) _swipeResult = 'No other users to swipe on.';
    });
  }

  Future<void> _swipe(bool isLike) async {
    if (userId == null || targetUserId == null) {
      setState(() {
        _swipeResult = 'Error: User IDs not set.';
      });
      return;
    }
    try {
      await api.recordSwipe(
        userId: userId!,
        targetUserId: targetUserId!,
        isLike: isLike,
      );
      setState(() {
        _swipeResult = isLike ? 'Liked!' : 'Disliked!';
        _currentIndex++;
        if (_currentIndex < _usersToSwipe.length) {
          _currentTargetUser = _usersToSwipe[_currentIndex];
          targetUserId =
              _currentTargetUser!['id'] is int
                  ? _currentTargetUser!['id']
                  : int.tryParse(_currentTargetUser!['id'].toString()) ?? 0;
        } else {
          _currentTargetUser = null;
          targetUserId = null;
          _swipeResult = 'No more users to swipe on.';
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(isLike ? 'Liked!' : 'Disliked!')));
    } catch (e) {
      setState(() {
        _swipeResult = 'Error: ${e.toString()}';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse/Swipe')),
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : _currentTargetUser == null
                ? Text(_swipeResult ?? 'No users to swipe on.')
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentTargetUser!['name'] ??
                                  _currentTargetUser!['email'] ??
                                  'Unknown',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_currentTargetUser!['email'] != null)
                              Text(
                                _currentTargetUser!['email'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            // Add more fields as needed
                          ],
                        ),
                      ),
                    ),
                    if (_swipeResult != null) ...[
                      Text(_swipeResult!, key: Key('swipeResult')),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed:
                              (userId != null && targetUserId != null)
                                  ? () => _swipe(false)
                                  : null,
                          child: const Text('Swipe Left'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed:
                              (userId != null && targetUserId != null)
                                  ? () => _swipe(true)
                                  : null,
                          child: const Text('Swipe Right'),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}
