import 'package:flutter/material.dart';
import 'demo_startup_screen.dart';
import 'services/demo_service.dart';

// Import your existing app screens here
// import 'your_main_app_screen.dart';
// import 'your_login_screen.dart';

class DemoApp extends StatefulWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  bool _demoInitialized = false;
  String? _demoToken;
  Map<String, String>? _demoUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dating App Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _buildCurrentScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildCurrentScreen() {
    // Show demo startup if in demo mode and not initialized
    if (DemoService.isDemoMode && !_demoInitialized) {
      return DemoStartupScreen(
        onDemoReady: _onDemoReady,
        onDemoSkipped: _onDemoSkipped,
      );
    }

    // Show main app with demo context
    if (_demoInitialized && _demoToken != null) {
      return DemoMainScreen(
        token: _demoToken!,
        user: _demoUser!,
      );
    }

    // Regular app flow (you can replace this with your existing main screen)
    return const RegularAppScreen();
  }

  void _onDemoReady(String token, Map<String, String> user) {
    setState(() {
      _demoInitialized = true;
      _demoToken = token;
      _demoUser = user;
    });
  }

  void _onDemoSkipped() {
    setState(() {
      _demoInitialized = true;
    });
  }
}

// Demo-enabled main screen
class DemoMainScreen extends StatefulWidget {
  final String token;
  final Map<String, String> user;

  const DemoMainScreen({
    Key? key,
    required this.token,
    required this.user,
  }) : super(key: key);

  @override
  State<DemoMainScreen> createState() => _DemoMainScreenState();
}

class _DemoMainScreenState extends State<DemoMainScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _profiles = [];
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDemoData();
  }

  Future<void> _loadDemoData() async {
    setState(() => _isLoading = true);

    // Load profiles and matches
    final profiles = await DemoService.getDemoProfiles(widget.token);
    final matches =
        await DemoService.getMatches(widget.token, 1); // Assuming user ID 1

    setState(() {
      _profiles = profiles;
      _matches = matches;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dating App'),
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
        actions: [
          // Demo indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'DEMO',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pink.shade400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildDiscoverPage();
      case 1:
        return _buildMatchesPage();
      case 2:
        return _buildMessagesPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildDiscoverPage();
    }
  }

  Widget _buildDiscoverPage() {
    if (_profiles.isEmpty) {
      return const Center(
        child: Text('No profiles available for swiping'),
      );
    }

    return Column(
      children: [
        // Demo status
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.green.shade50,
          child: Text(
            '✅ Logged in as ${widget.user['name']} - ${_profiles.length} profiles loaded',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green.shade700),
          ),
        ),
        // Profile cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _profiles.length,
            itemBuilder: (context, index) {
              final profile = _profiles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.pink.shade100,
                            child: Text(
                              profile['name']?[0] ?? '?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${profile['age'] ?? '?'} år, ${profile['city'] ?? '?'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile['bio'] ?? 'No bio available',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FloatingActionButton(
                            heroTag: 'pass_$index',
                            onPressed: () => _swipeProfile(profile, false),
                            backgroundColor: Colors.grey,
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                          FloatingActionButton(
                            heroTag: 'like_$index',
                            onPressed: () => _swipeProfile(profile, true),
                            backgroundColor: Colors.pink,
                            child:
                                const Icon(Icons.favorite, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesPage() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: Text(
            '💕 ${_matches.length} matches found',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue.shade700),
          ),
        ),
        Expanded(
          child: _matches.isEmpty
              ? const Center(child: Text('No matches yet'))
              : ListView.builder(
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    final match = _matches[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.favorite),
                      ),
                      title: Text('Match #${match['matchId']}'),
                      subtitle: Text(
                          'Score: ${match['compatibilityScore']?.toStringAsFixed(1)}%'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMessagesPage() {
    return const Center(
      child: Text('Messages (coming soon in demo)'),
    );
  }

  Widget _buildProfilePage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.pink.shade100,
            child: Text(
              widget.user['name']?[0] ?? '?',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.user['name'] ?? 'Demo User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.user['description'] ?? 'Demo account',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _switchDemoUser,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Switch Demo User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _swipeProfile(Map<String, dynamic> profile, bool liked) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          liked
              ? '❤️ You liked ${profile['name']}'
              : '👎 You passed ${profile['name']}',
        ),
        backgroundColor: liked ? Colors.green : Colors.grey,
        duration: const Duration(seconds: 1),
      ),
    );

    // In a real app, you'd call the API to record the swipe
    // For demo, just remove from list
    setState(() {
      _profiles.remove(profile);
    });
  }

  void _switchDemoUser() {
    // Reset and go back to user selection
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const DemoApp(),
      ),
    );
  }
}

// Placeholder for regular app when not in demo mode
class RegularAppScreen extends StatelessWidget {
  const RegularAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dating App'),
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 64, color: Colors.pink),
            SizedBox(height: 16),
            Text(
              'Welcome to Dating App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Regular app mode - implement your login flow here'),
          ],
        ),
      ),
    );
  }
}
