import 'package:flutter/material.dart';
import '../models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  int _currentIndex = 0;
  List<UserProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadProfiles();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadProfiles() {
    // Simulate loading profiles from backend
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _profiles = [
          UserProfile(
            userId: '1',
            firstName: 'Emma',
            lastName: 'Johnson',
            dateOfBirth: DateTime(1999, 5, 15),
            bio: 'Love hiking and photography 📸',
            photoUrls: ['https://picsum.photos/400/600?random=1'],
            interests: ['Photography', 'Hiking', 'Travel'],
          ),
          UserProfile(
            userId: '2',
            firstName: 'Sofia',
            lastName: 'Martinez',
            dateOfBirth: DateTime(2001, 8, 22),
            bio: 'Yoga instructor & coffee enthusiast ☕',
            photoUrls: ['https://picsum.photos/400/600?random=2'],
            interests: ['Yoga', 'Coffee', 'Art'],
          ),
          UserProfile(
            userId: '3',
            firstName: 'Isabella',
            lastName: 'Thompson',
            dateOfBirth: DateTime(1997, 3, 10),
            bio: 'Chef who loves to cook for friends 👩‍🍳',
            photoUrls: ['https://picsum.photos/400/600?random=3'],
            interests: ['Cooking', 'Wine', 'Music'],
          ),
        ];
        _isLoading = false;
      });
    });
  }

  void _onSwipe(bool isLike) {
    if (_profiles.isEmpty) return;

    _animationController.forward().then((_) {
      setState(() {
        if (_currentIndex < _profiles.length - 1) {
          _currentIndex++;
        } else {
          // Load more profiles
          _currentIndex = 0;
          _loadProfiles();
        }
      });
      _animationController.reverse();
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isLike
              ? '💖 Liked ${_profiles[_currentIndex].firstName}!'
              : '👋 Passed',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: isLike ? Colors.pink : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.pink),
                      SizedBox(height: 16),
                      Text('Finding amazing people near you...'),
                    ],
                  ),
                )
                : _profiles.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text('No more profiles to show'),
                      Text('Check back later for new matches!'),
                    ],
                  ),
                )
                : Stack(
                  children: [
                    // Background gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFF6B9D), Color(0xFFFF8E8E)],
                        ),
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              const Text(
                                'Discover',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // TODO: Open filter settings
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Card stack
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Transform.rotate(
                                    angle: _rotationAnimation.value,
                                    child: _buildProfileCard(
                                      _profiles[_currentIndex],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FloatingActionButton(
                                heroTag: 'pass',
                                onPressed: () => _onSwipe(false),
                                backgroundColor: Colors.white,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              ),
                              FloatingActionButton.large(
                                heroTag: 'like',
                                onPressed: () => _onSwipe(true),
                                backgroundColor: Colors.pink,
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              FloatingActionButton(
                                heroTag: 'superlike',
                                onPressed: () => _onSwipe(true),
                                backgroundColor: Colors.blue,
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        profile.photoUrls.isNotEmpty
                            ? profile.photoUrls.first
                            : 'https://picsum.photos/400/600?random=1',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                profile.firstName,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${profile.age}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '2.5 km away',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bio and interests
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.bio ?? '',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            profile.interests.take(3).map((interest) {
                              return Chip(
                                label: Text(
                                  interest,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.pink[50],
                                side: BorderSide(color: Colors.pink[200]!),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
