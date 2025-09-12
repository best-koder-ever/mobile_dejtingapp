import 'package:flutter/material.dart';
import 'services/demo_service.dart';

void main() {
  runApp(const SimpleDemoApp());
}

class SimpleDemoApp extends StatelessWidget {
  const SimpleDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dating App Demo',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const DemoTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DemoTestScreen extends StatefulWidget {
  const DemoTestScreen({Key? key}) : super(key: key);

  @override
  State<DemoTestScreen> createState() => _DemoTestScreenState();
}

class _DemoTestScreenState extends State<DemoTestScreen> {
  bool _isLoading = false;
  String _status = 'Ready to test demo integration';
  String? _token;
  List<Map<String, dynamic>> _profiles = [];
  Map<String, String>? _currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Integration Test'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Demo Mode Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DemoService.isDemoMode
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                border: Border.all(
                  color: DemoService.isDemoMode ? Colors.green : Colors.orange,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DemoService.isDemoMode
                        ? '✅ Demo Mode Enabled'
                        : '⚠️ Demo Mode Disabled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: DemoService.isDemoMode
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Debug mode: ${DemoService.isDemoMode}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status
            Text(
              _status,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Action buttons
            if (_token == null) ...[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _initializeDemo,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.rocket_launch),
                label: Text(_isLoading ? 'Initializing...' : 'Start Demo'),
              ),
            ] else ...[
              Text(
                'Logged in as: ${_currentUser?['name'] ?? 'Unknown'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Loaded ${_profiles.length} profiles',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadProfiles,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Profiles'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset Demo'),
              ),
            ],

            const SizedBox(height: 24),

            // Profiles list
            if (_profiles.isNotEmpty) ...[
              const Text(
                'Demo Profiles:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _profiles.length,
                  itemBuilder: (context, index) {
                    final profile = _profiles[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.pink.shade100,
                          child: Text(
                            profile['name']?[0] ?? '?',
                            style: TextStyle(
                              color: Colors.pink.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(profile['name'] ?? 'Unknown'),
                        subtitle:
                            Text('${profile['age']} år, ${profile['city']}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _initializeDemo() async {
    setState(() {
      _isLoading = true;
      _status = 'Initializing demo environment...';
    });

    try {
      final result = await DemoService.initializeDemoEnvironment();

      setState(() {
        _isLoading = false;
        _status = result.message;

        if (result.success) {
          _token = result.token;
          _currentUser = result.user;
        }
      });

      if (result.success && _token != null) {
        await _loadProfiles();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _loadProfiles() async {
    if (_token == null) return;

    setState(() => _status = 'Loading profiles...');

    try {
      final profiles = await DemoService.getDemoProfiles(_token!);
      setState(() {
        _profiles = profiles;
        _status = 'Loaded ${profiles.length} profiles successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading profiles: $e';
      });
    }
  }

  void _reset() {
    setState(() {
      _token = null;
      _profiles = [];
      _currentUser = null;
      _status = 'Ready to test demo integration';
    });
  }
}
