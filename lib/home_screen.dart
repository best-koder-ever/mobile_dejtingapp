import 'package:flutter/material.dart';
import 'swipe_screen.dart';
import 'profile_screen.dart';
import 'matches_screen.dart';
import 'api_services.dart';
import 'screens/auth_screens.dart';
import 'models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _needsProfile = false;

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  Future<void> _checkUserProfile() async {
    try {
      _userProfile = await userApi.getMyProfile();
      setState(() {
        _isLoading = false;
        _needsProfile = false;
      });
    } catch (e) {
      // User doesn't have a profile yet, they need to create one
      setState(() {
        _isLoading = false;
        _needsProfile = true;
      });
    }
  }

  Future<void> _logout() async {
    await authApi.logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget get _currentScreen {
    if (_needsProfile) {
      return const ProfileScreen(isFirstTime: true);
    }

    switch (_selectedIndex) {
      case 0:
        return const SwipeScreen();
      case 1:
        return const MatchesScreen();
      case 2:
        return ProfileScreen(userProfile: _userProfile);
      default:
        return const SwipeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.pink[400]),
              const SizedBox(height: 16),
              const Text('Loading your profile...'),
            ],
          ),
        ),
      );
    }

    if (_needsProfile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Complete Your Profile'),
          backgroundColor: Colors.pink[400],
          foregroundColor: Colors.white,
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        body: const ProfileScreen(isFirstTime: true),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${_userProfile?.firstName ?? 'User'}!'),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Discover',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Matches'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink[400],
        onTap: _onItemTapped,
      ),
    );
  }
}
