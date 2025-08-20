import 'package:flutter/material.dart';
import 'api_services.dart';
import 'models.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<UserProfile> _matches = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final matches = await matchmakingApi.getMatches();
      setState(() {
        _matches = matches;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load matches: $e';
        _loading = false;
      });
    }
  }

  Widget _buildMatchCard(UserProfile match) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage:
              match.photoUrls.isNotEmpty
                  ? NetworkImage(match.photoUrls.first)
                  : null,
          child:
              match.photoUrls.isEmpty
                  ? const Icon(Icons.person, size: 30)
                  : null,
        ),
        title: Text(
          '${match.firstName} ${match.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Age: ${match.age}', style: const TextStyle(fontSize: 14)),
            if (match.city?.isNotEmpty == true)
              Text(
                'Location: ${match.city}',
                style: const TextStyle(fontSize: 14),
              ),
            if (match.bio?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  match.bio!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chat, color: Colors.pink),
        onTap: () {
          _showMatchDetails(match);
        },
      ),
    );
  }

  void _showMatchDetails(UserProfile match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photos
                            if (match.photoUrls.isNotEmpty) ...[
                              SizedBox(
                                height: 200,
                                child: PageView.builder(
                                  itemCount: match.photoUrls.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            match.photoUrls[index],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            // Name and age
                            Text(
                              '${match.firstName} ${match.lastName}, ${match.age}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Location and occupation
                            if (match.city?.isNotEmpty == true ||
                                match.occupation?.isNotEmpty == true) ...[
                              Text(
                                [
                                  if (match.city?.isNotEmpty == true)
                                    match.city!,
                                  if (match.occupation?.isNotEmpty == true)
                                    match.occupation!,
                                ].join(' • '),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Bio
                            if (match.bio?.isNotEmpty == true) ...[
                              const Text(
                                'About',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                match.bio!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Interests
                            if (match.interests.isNotEmpty) ...[
                              const Text(
                                'Interests',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    match.interests.map((interest) {
                                      return Chip(
                                        label: Text(interest),
                                        backgroundColor: Colors.pink
                                            .withOpacity(0.1),
                                        side: const BorderSide(
                                          color: Colors.pink,
                                        ),
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Chat feature coming soon!',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.chat),
                                    label: const Text('Start Chat'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Show unmatch confirmation
                                    final shouldUnmatch = await showDialog<
                                      bool
                                    >(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text('Unmatch'),
                                            content: Text(
                                              'Are you sure you want to unmatch with ${match.firstName}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child: const Text('Unmatch'),
                                              ),
                                            ],
                                          ),
                                    );
                                    if (shouldUnmatch == true) {
                                      // TODO: Implement unmatch functionality
                                      Navigator.pop(context);
                                      _loadMatches(); // Refresh matches
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                  ),
                                  child: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Matches'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadMatches,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _matches.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      'No matches yet!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Start swiping to find your perfect match',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadMatches,
                child: ListView.builder(
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    return _buildMatchCard(_matches[index]);
                  },
                ),
              ),
    );
  }
}
