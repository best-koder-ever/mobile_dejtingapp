import 'package:flutter/material.dart';
import 'services/demo_service.dart';

class DemoStartupScreen extends StatefulWidget {
  final Function(String token, Map<String, String> user) onDemoReady;
  final VoidCallback onDemoSkipped;

  const DemoStartupScreen({
    Key? key,
    required this.onDemoReady,
    required this.onDemoSkipped,
  }) : super(key: key);

  @override
  State<DemoStartupScreen> createState() => _DemoStartupScreenState();
}

class _DemoStartupScreenState extends State<DemoStartupScreen> {
  bool _isInitializing = false;
  String _statusMessage = '';
  bool _showUserSelection = false;
  DemoInitResult? _initResult;

  @override
  void initState() {
    super.initState();
    if (DemoService.isDemoMode) {
      _initializeDemo();
    }
  }

  Future<void> _initializeDemo() async {
    setState(() {
      _isInitializing = true;
      _statusMessage = 'Starting demo environment...';
    });

    final result = await DemoService.initializeDemoEnvironment();

    setState(() {
      _isInitializing = false;
      _initResult = result;
      _statusMessage = result.message;
      _showUserSelection = result.success;
    });

    if (result.success && result.token != null && result.user != null) {
      // Auto-proceed with first user after a brief delay
      await Future.delayed(Duration(seconds: 2));
      widget.onDemoReady(result.token!, result.user!);
    }
  }

  Future<void> _loginAsUser(String email) async {
    setState(() {
      _isInitializing = true;
      _statusMessage = 'Logging in...';
    });

    final result = await DemoService.loginWithDemoUser(email);

    if (result.success && result.token != null) {
      final user = DemoService.demoUsers.firstWhere((u) => u['email'] == email);
      widget.onDemoReady(result.token!, user);
    } else {
      setState(() {
        _isInitializing = false;
        _statusMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!DemoService.isDemoMode) {
      // Not in demo mode, skip to normal app
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDemoSkipped();
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Demo Mode Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.science,
                        color: Colors.orange.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEMO MODE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          Text(
                            'Testing with realistic Swedish dating profiles',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // App Logo/Title
              Icon(
                Icons.favorite,
                size: 80,
                color: Colors.pink.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Dating App Demo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade700,
                ),
              ),

              const SizedBox(height: 40),

              // Status/Loading Area
              if (_isInitializing) ...[
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
                ),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ] else if (_showUserSelection &&
                  _initResult?.success == true) ...[
                Text(
                  '✅ Demo environment ready!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Choose a demo user to login as:',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: DemoService.demoUsers.length,
                    itemBuilder: (context, index) {
                      final user = DemoService.demoUsers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.pink.shade100,
                            child: Text(
                              user['name']![0],
                              style: TextStyle(
                                color: Colors.pink.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(user['description']!),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _loginAsUser(user['email']!),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                // Error or initial state
                Icon(
                  _initResult?.success == false
                      ? Icons.error
                      : Icons.play_circle,
                  size: 64,
                  color:
                      _initResult?.success == false ? Colors.red : Colors.blue,
                ),
                const SizedBox(height: 24),
                Text(
                  _statusMessage.isEmpty
                      ? 'Ready to start demo'
                      : _statusMessage,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_initResult?.success == false) ...[
                  ElevatedButton.icon(
                    onPressed: _initializeDemo,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Demo Setup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else if (_statusMessage.isEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: _initializeDemo,
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Start Demo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextButton(
                  onPressed: widget.onDemoSkipped,
                  child: const Text('Skip Demo Mode'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
