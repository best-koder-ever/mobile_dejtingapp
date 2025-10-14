import 'package:flutter/material.dart';
import 'api_services.dart';
import 'models.dart';
import 'services/api_service.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  List<UserProfile> _profiles = [];
  int _currentIndex = 0;
  bool _loading = true;
  String? _errorMessage;
  bool _swiping = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await AppState().initialize();
      final userId = AppState().userId ?? await userApi.getCurrentUserId();
      final profiles = await userApi.getAllProfiles();
      setState(() {
        _currentUserId = userId;
        _profiles = userId == null
            ? profiles
            : profiles.where((p) => p.userId != userId).toList();
        _currentIndex = 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profiles: $e';
        _loading = false;
      });
    }
  }

  Future<void> _swipe(bool isLike) async {
    if (_currentIndex >= _profiles.length || _swiping) return;

    setState(() {
      _swiping = true;
    });

    try {
      final userId = _currentUserId ?? await userApi.getCurrentUserId();
      if (userId == null) {
        setState(() {
          _errorMessage =
              'Unable to determine current user. Please re-login and try again.';
          _swiping = false;
        });
        return;
      }

      _currentUserId = userId;
      final currentProfile = _profiles[_currentIndex];
      final response = await swipeApi.recordSwipe(
        userId: userId,
        targetUserId: currentProfile.userId,
        isLike: isLike,
      );

      if (response.isMatch) {
        _showMatchDialog(currentProfile);
      }

      setState(() {
        _currentIndex++;
        _swiping = false;
      });

      // Load more profiles if we're running low
      if (_currentIndex >= _profiles.length - 2) {
        _loadMoreProfiles();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to record swipe: $e';
        _swiping = false;
      });
    }
  }

  Future<void> _loadMoreProfiles() async {
    try {
      final moreProfiles = await userApi.getAllProfiles();
      final currentUserId = _currentUserId ?? await userApi.getCurrentUserId();
      _currentUserId = currentUserId;
      setState(() {
        _profiles.addAll(
          moreProfiles
              .where(
                (p) =>
                    p.userId != currentUserId &&
                    !_profiles.any((existing) => existing.userId == p.userId),
              )
              .toList(),
        );
      });
    } catch (e) {
      // Ignore errors when loading more profiles
    }
  }

  void _showMatchDialog(UserProfile matchedProfile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 It\'s a Match!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: matchedProfile.photoUrls.isNotEmpty
                  ? NetworkImage(matchedProfile.photoUrls.first)
                  : null,
              child: matchedProfile.photoUrls.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              'You matched with ${matchedProfile.firstName}!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Swiping'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to matches screen
              DefaultTabController.of(context).animateTo(2);
            },
            child: const Text('View Matches'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: profile.photoUrls.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(profile.photoUrls.first),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: profile.photoUrls.isEmpty ? Colors.grey[300] : null,
              ),
              child: profile.photoUrls.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Profile info
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.firstName}, ${profile.age}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile.bio?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.bio!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (profile.interests.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: profile.interests.take(3).map((interest) {
                        return Chip(
                          label: Text(interest),
                          backgroundColor: Colors.white.withOpacity(0.9),
                          labelStyle: const TextStyle(fontSize: 12),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadProfiles,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _currentIndex >= _profiles.length
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, size: 64, color: Colors.pink),
                          SizedBox(height: 20),
                          Text(
                            'No more profiles!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Check back later for new matches',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        // Profile cards stack
                        for (int i = _currentIndex;
                            i < _currentIndex + 2 && i < _profiles.length;
                            i++)
                          Positioned(
                            top: (i - _currentIndex) * 10.0,
                            left: (i - _currentIndex) * 5.0,
                            right: (i - _currentIndex) * 5.0,
                            bottom: 120,
                            child: _buildProfileCard(_profiles[i]),
                          ),
                        // Action buttons
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Pass button
                              FloatingActionButton(
                                onPressed:
                                    _swiping ? null : () => _swipe(false),
                                backgroundColor: Colors.red,
                                heroTag: "pass",
                                child: const Icon(Icons.close,
                                    color: Colors.white),
                              ),
                              // Like button
                              FloatingActionButton(
                                onPressed: _swiping ? null : () => _swipe(true),
                                backgroundColor: Colors.green,
                                heroTag: "like",
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Loading overlay
                        if (_swiping)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
    );
  }
}
