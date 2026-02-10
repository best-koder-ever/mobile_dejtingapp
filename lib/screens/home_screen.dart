import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api_services.dart';
import '../models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Animation
  late AnimationController _swipeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  // State
  List<MatchCandidate> _candidates = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSwiping = false;
  String? _errorMessage;

  // Drag state
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  // Prefetch threshold — load more when this many cards remain
  static const _prefetchThreshold = 3;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
    );
    _loadCandidates();
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  // ─── Data Loading ───

  Future<void> _loadCandidates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final candidates = await matchmakingApi.getCandidates();
      setState(() {
        _candidates = candidates;
        _currentIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load candidates: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load profiles. Check your connection.';
      });
    }
  }

  Future<void> _prefetchIfNeeded() async {
    final remaining = _candidates.length - _currentIndex - 1;
    if (remaining <= _prefetchThreshold) {
      try {
        final more = await matchmakingApi.getCandidates(page: 2);
        if (more.isNotEmpty && mounted) {
          setState(() => _candidates.addAll(more));
        }
      } catch (_) {
        // Swallow — best-effort prefetch
      }
    }
  }

  // ─── Swipe Logic ───

  Future<void> _onSwipe(bool isLike) async {
    if (_isSwiping || _currentIndex >= _candidates.length) return;

    final candidate = _candidates[_currentIndex];
    setState(() => _isSwiping = true);

    // Animate card off screen
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isLike ? 1.5 : -1.5, -0.2),
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: isLike ? 0.3 : -0.3,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    await _swipeController.forward();

    // Call backend
    final response = await matchmakingApi.swipe(
      targetUserId: candidate.userId,
      isLike: isLike,
    );

    // Check for match
    if (response != null && mounted) {
      final swipeResult = SwipeResponse.fromJson(response);
      if (swipeResult.isMatch) {
        _showMatchCelebration(candidate, swipeResult);
      }
    }

    // Advance to next card
    if (mounted) {
      setState(() {
        _currentIndex++;
        _isSwiping = false;
        _dragOffset = Offset.zero;
      });
      _swipeController.reset();
      _prefetchIfNeeded();
    }
  }

  void _onDragStart(DragStartDetails details) {
    if (_isSwiping) return;
    setState(() => _isDragging = true);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isSwiping) return;
    setState(() => _dragOffset += details.delta);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isSwiping) return;
    setState(() => _isDragging = false);

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_dragOffset.dx.abs() > threshold) {
      _onSwipe(_dragOffset.dx > 0); // right = like, left = pass
    } else {
      // Snap back
      setState(() => _dragOffset = Offset.zero);
    }
  }

  // ─── Match Celebration ───

  void _showMatchCelebration(MatchCandidate candidate, SwipeResponse result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _MatchCelebrationDialog(
        candidate: candidate,
        onSendMessage: () {
          Navigator.of(ctx).pop();
          // TODO: Navigate to chat with matchId
        },
        onKeepSwiping: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();
    if (_currentIndex >= _candidates.length) return _buildEmptyState();
    return _buildDiscoverView();
  }

  // ─── States ───

  Widget _buildLoadingState() {
    return Container(
      decoration: _backgroundGradient(),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Finding amazing people near you...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: _backgroundGradient(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 72, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCandidates,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6B9D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: _backgroundGradient(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore_outlined, size: 80, color: Colors.white70),
              const SizedBox(height: 16),
              const Text(
                "You've seen everyone!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new people near you.\nOr adjust your search preferences.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _loadCandidates,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6B9D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Main Discover View ───

  Widget _buildDiscoverView() {
    final candidate = _candidates[_currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final dragPercent = _dragOffset.dx / screenWidth;

    return Stack(
      children: [
        // Background gradient
        Container(decoration: _backgroundGradient()),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 12),

              // Card stack
              Expanded(
                child: Stack(
                  children: [
                    // Next card peek (if available)
                    if (_currentIndex + 1 < _candidates.length)
                      Positioned.fill(
                        child: Transform.scale(
                          scale: 0.92 + (0.08 * dragPercent.abs().clamp(0.0, 1.0)),
                          child: Opacity(
                            opacity: 0.6 + (0.4 * dragPercent.abs().clamp(0.0, 1.0)),
                            child: _buildCandidateCard(
                              _candidates[_currentIndex + 1],
                              interactive: false,
                            ),
                          ),
                        ),
                      ),

                    // Current card (animated or draggable)
                    Positioned.fill(
                      child: GestureDetector(
                        onPanStart: _onDragStart,
                        onPanUpdate: _onDragUpdate,
                        onPanEnd: _onDragEnd,
                        child: AnimatedBuilder(
                          animation: _swipeController,
                          builder: (context, child) {
                            final animOffset = _swipeController.isAnimating
                                ? _slideAnimation.value * screenWidth
                                : _dragOffset;
                            final rotation = _swipeController.isAnimating
                                ? _rotationAnimation.value
                                : dragPercent * 0.3;
                            final opacity = _swipeController.isAnimating
                                ? _fadeAnimation.value
                                : 1.0;

                            return Transform.translate(
                              offset: animOffset,
                              child: Transform.rotate(
                                angle: rotation,
                                child: Opacity(
                                  opacity: opacity.clamp(0.0, 1.0),
                                  child: Stack(
                                    children: [
                                      _buildCandidateCard(candidate, interactive: true),

                                      // Like / Nope overlay
                                      if (_isDragging && _dragOffset.dx.abs() > 40)
                                        Positioned(
                                          top: 40,
                                          left: _dragOffset.dx > 0 ? 24 : null,
                                          right: _dragOffset.dx < 0 ? 24 : null,
                                          child: Transform.rotate(
                                            angle: _dragOffset.dx > 0 ? -0.3 : 0.3,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: _dragOffset.dx > 0
                                                      ? Colors.green
                                                      : Colors.red,
                                                  width: 3,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _dragOffset.dx > 0 ? 'LIKE' : 'NOPE',
                                                style: TextStyle(
                                                  color: _dragOffset.dx > 0
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Widgets ───

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.location_on, color: Colors.white),
        const Text(
          'Discover',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          onPressed: () {
            // TODO: Open filter settings
          },
        ),
      ],
    );
  }

  Widget _buildCandidateCard(MatchCandidate candidate, {required bool interactive}) {
    final photoUrl = candidate.photoUrl ??
        (candidate.photoUrls.isNotEmpty ? candidate.photoUrls.first : null);
    final compatibilityPercent = (candidate.compatibility * 100).round();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            if (photoUrl != null)
              CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 80, color: Colors.grey),
                ),
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 80, color: Colors.grey),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.45, 0.7, 1.0],
                ),
              ),
            ),

            // Compatibility Badge
            if (compatibilityPercent > 0)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B46C1), Color(0xFF9333EA)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9333EA).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.whatshot, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$compatibilityPercent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Info overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name and Age
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${candidate.displayName}, ${candidate.age}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Location / Distance
                    if (candidate.distanceKm != null || candidate.city != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _formatDistance(candidate),
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),

                    // Occupation
                    if (candidate.occupation != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.work_outline, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              candidate.occupation!,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Bio
                    if (candidate.bio != null && candidate.bio!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        candidate.bio!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                      ),
                    ],

                    // Shared interests
                    if (candidate.interestsOverlap.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: candidate.interestsOverlap.take(4).map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              interest,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass
          _buildCircleButton(
            icon: Icons.close,
            color: Colors.grey,
            bgColor: Colors.white,
            size: 56,
            onTap: () => _onSwipe(false),
          ),
          // Super Like
          _buildCircleButton(
            icon: Icons.star,
            color: Colors.white,
            bgColor: const Color(0xFF4ECDC4),
            size: 48,
            onTap: () => _onSwipe(true), // treat as like for now
          ),
          // Like
          _buildCircleButton(
            icon: Icons.favorite,
            color: Colors.white,
            bgColor: Colors.pink,
            size: 64,
            onTap: () => _onSwipe(true),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }

  // ─── Helpers ───

  String _formatDistance(MatchCandidate candidate) {
    if (candidate.distanceKm != null) {
      final km = candidate.distanceKm!;
      if (km < 1) return '${(km * 1000).round()} m away';
      return '${km.toStringAsFixed(1)} km away';
    }
    return candidate.city ?? '';
  }

  BoxDecoration _backgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF6B9D), Color(0xFFFF8E8E)],
      ),
    );
  }
}

// ─── Match Celebration Dialog ───

class _MatchCelebrationDialog extends StatelessWidget {
  final MatchCandidate candidate;
  final VoidCallback onSendMessage;
  final VoidCallback onKeepSwiping;

  const _MatchCelebrationDialog({
    required this.candidate,
    required this.onSendMessage,
    required this.onKeepSwiping,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = candidate.photoUrl ??
        (candidate.photoUrls.isNotEmpty ? candidate.photoUrls.first : null);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B9D), Color(0xFFFF8E8E), Color(0xFFFFC371)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "It's a Match! 🎉",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You and ${candidate.displayName} liked each other',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 24),

            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 120, height: 120,
                        color: Colors.white24,
                        child: const Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 120, height: 120,
                        color: Colors.white24,
                        child: const Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                    )
                  : Container(
                      width: 120, height: 120,
                      color: Colors.white24,
                      child: const Icon(Icons.person, size: 60, color: Colors.white),
                    ),
            ),

            const SizedBox(height: 28),

            // Send Message button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6B9D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Send a Message',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Keep Swiping button
            TextButton(
              onPressed: onKeepSwiping,
              child: Text(
                'Keep Swiping',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
