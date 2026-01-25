import 'package:flutter/material.dart';
import 'api_services.dart';
import 'models.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final List<MatchCandidate> _candidates = [];
  int _currentIndex = 0;
  bool _loading = true;
  String? _errorMessage;
  bool _swiping = false;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates(reset: true);
  }

  Future<void> _loadCandidates({bool reset = false}) async {
    setState(() {
      if (reset) {
        _loading = true;
        _currentIndex = 0;
        _candidates.clear();
        _currentPage = 1;
        _hasMore = true;
      }
      _errorMessage = null;
    });

    try {
      final candidates = await matchmakingApi.getCandidates(
        page: _currentPage,
        pageSize: 20,
      );
      setState(() {
        _candidates.addAll(candidates);
        _loading = false;
        _hasMore = candidates.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load recommendations: $e';
        _loading = false;
      });
    }
  }

  Future<void> _swipe(bool isLike) async {
    if (_currentIndex >= _candidates.length || _swiping) return;

    setState(() {
      _swiping = true;
    });

    try {
      final candidate = _candidates[_currentIndex];
      final response = await matchmakingApi.swipe(
        targetUserId: candidate.userId,
        isLike: isLike,
      );

      final isMatch = response?['isMatch'] == true ||
          response?['matchCreated'] == true ||
          response?['matchId'] != null;

      if (isMatch) {
        _showMatchDialog(candidate);
      }

      setState(() {
        _currentIndex++;
        _swiping = false;
      });

      // Load more profiles if we're running low
      if (_currentIndex >= _candidates.length - 2) {
        _loadMoreCandidates();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to record swipe: $e';
        _swiping = false;
      });
    }
  }

  Future<void> _loadMoreCandidates() async {
    if (_isFetchingMore || !_hasMore) {
      return;
    }

    setState(() {
      _isFetchingMore = true;
      _currentPage += 1;
    });

    try {
      final candidates = await matchmakingApi.getCandidates(
        page: _currentPage,
        pageSize: 20,
      );
      setState(() {
        _candidates.addAll(candidates);
        _hasMore = candidates.isNotEmpty;
      });
    } catch (_) {
      // Ignore pagination errors to keep primary list usable
      setState(() {
        _currentPage -= 1;
      });
    } finally {
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  void _showMatchDialog(MatchCandidate matchedProfile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 It\'s a Match!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: matchedProfile.photoUrl != null
                  ? NetworkImage(matchedProfile.photoUrl!)
                  : null,
              child: matchedProfile.photoUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              'You matched with ${matchedProfile.displayName}!',
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

  Widget _buildCompatibilityBadge(double compatibility) {
    final percentage = (compatibility * 100).round();
    Color badgeColor;
    IconData icon;

    if (percentage >= 80) {
      badgeColor = Colors.green;
      icon = Icons.favorite;
    } else if (percentage >= 60) {
      badgeColor = Colors.orange;
      icon = Icons.favorite_border;
    } else {
      badgeColor = Colors.grey;
      icon = Icons.favorite_border;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProfileCard(MatchCandidate profile) {
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
                image: profile.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(profile.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: profile.photoUrl == null ? Colors.grey[300] : null,
              ),
              child: profile.photoUrl == null
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
                    Colors.black.withValues(alpha: 0.7),
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
                  Row(
                    children: [
                      Text(
                        '${profile.displayName}, ${profile.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (profile.distanceKm != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${profile.distanceKm!.round()} km',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (profile.compatibility > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCompatibilityBadge(profile.compatibility),
                        const SizedBox(width: 8),
                        Text(
                          '${(profile.compatibility * 100).round()}% Match',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (profile.interestsOverlap.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          profile.interestsOverlap.take(5).map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.pink.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite,
                                size: 14,
                                color: Colors.pink,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                interest,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
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
              onPressed: () => _loadCandidates(reset: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_candidates.isEmpty || _currentIndex >= _candidates.length) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 64,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No more profiles!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You\'ve seen all available matches for today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tip: Broaden your preferences',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adjust your distance or age range in Settings to see more matches',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Check back tomorrow for fresh recommendations!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        for (int i = _currentIndex;
            i < _currentIndex + 2 && i < _candidates.length;
            i++)
          Positioned(
            top: (i - _currentIndex) * 10.0,
            left: (i - _currentIndex) * 5.0,
            right: (i - _currentIndex) * 5.0,
            bottom: 120,
            child: _buildProfileCard(_candidates[i]),
          ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: _swiping ? null : () => _swipe(false),
                backgroundColor: Colors.red,
                heroTag: 'pass',
                child: const Icon(Icons.close, color: Colors.white),
              ),
              FloatingActionButton(
                onPressed: _swiping ? null : () => _swipe(true),
                backgroundColor: Colors.green,
                heroTag: 'like',
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
            ],
          ),
        ),
        if (_swiping)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
