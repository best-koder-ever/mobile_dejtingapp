import 'package:flutter/material.dart';
import '../models.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Match> _matches = [];
  List<Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _matches = [
          Match(
            id: '1',
            userId1: 'demo_user',
            userId2: '1',
            matchedAt: DateTime.now().subtract(const Duration(hours: 2)),
            otherUserProfile: UserProfile(
              userId: '1',
              firstName: 'Emma',
              lastName: 'Johnson',
              dateOfBirth: DateTime(1999, 5, 15),
              bio: 'Love hiking and photography 📸',
              photoUrls: ['https://picsum.photos/400/600?random=1'],
              interests: ['Photography', 'Hiking'],
            ),
          ),
          Match(
            id: '2',
            userId1: 'demo_user',
            userId2: '2',
            matchedAt: DateTime.now().subtract(const Duration(days: 1)),
            otherUserProfile: UserProfile(
              userId: '2',
              firstName: 'Sofia',
              lastName: 'Martinez',
              dateOfBirth: DateTime(2001, 8, 22),
              bio: 'Yoga instructor & coffee enthusiast ☕',
              photoUrls: ['https://picsum.photos/400/600?random=2'],
              interests: ['Yoga', 'Coffee'],
            ),
          ),
          Match(
            id: '3',
            userId1: 'demo_user',
            userId2: '3',
            matchedAt: DateTime.now().subtract(const Duration(days: 2)),
            otherUserProfile: UserProfile(
              userId: '3',
              firstName: 'Isabella',
              lastName: 'Thompson',
              dateOfBirth: DateTime(1997, 3, 10),
              bio: 'Chef who loves to cook for friends 👩‍🍳',
              photoUrls: ['https://picsum.photos/400/600?random=3'],
              interests: ['Cooking', 'Wine'],
            ),
          ),
        ];

        _messages = [
          Message(
            id: '1',
            senderId: 'me',
            receiverId: '1',
            content: 'Hi Emma! I loved your hiking photos',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            isRead: true,
          ),
          Message(
            id: '2',
            senderId: '1',
            receiverId: 'me',
            content: 'Hey! Thanks for the like 😊',
            timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
            isRead: false,
          ),
        ];

        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.pink[100],
          tabs: const [Tab(text: 'New Matches'), Tab(text: 'Messages')],
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.pink),
              )
              : TabBarView(
                controller: _tabController,
                children: [_buildMatchesTab(), _buildMessagesTab()],
              ),
    );
  }

  Widget _buildMatchesTab() {
    if (_matches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No matches yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Keep swiping to find your perfect match!'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Matches',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                final profile = match.otherUserProfile;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _openChat(match),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            profile?.photoUrls.isNotEmpty == true
                                ? profile!.photoUrls.first
                                : 'https://picsum.photos/400/600?random=1',
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          child: Text(
                            profile?.firstName ?? 'Unknown',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                final profile = match.otherUserProfile;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        profile?.photoUrls.isNotEmpty == true
                            ? profile!.photoUrls.first
                            : 'https://picsum.photos/400/600?random=1',
                      ),
                    ),
                    title: Text(
                      profile?.firstName ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Say hello!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(match.matchedAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.pink,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _openChat(match),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    if (_messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Start chatting with your matches!'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        final profile = match.otherUserProfile;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                profile?.photoUrls.isNotEmpty == true
                    ? profile!.photoUrls.first
                    : 'https://picsum.photos/400/600?random=1',
              ),
            ),
            title: Text(
              profile?.firstName ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Start a conversation!',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              _formatTime(match.matchedAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            onTap: () => _openChat(match),
          ),
        );
      },
    );
  }

  void _openChat(Match match) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(match: match)),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

class ChatScreen extends StatefulWidget {
  final Match match;

  const ChatScreen({super.key, required this.match});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    final profile = widget.match.otherUserProfile;
    setState(() {
      _messages = [
        Message(
          id: '1',
          senderId: 'me',
          receiverId: profile?.userId ?? 'unknown',
          content: 'Hi ${profile?.firstName ?? 'there'}! I loved your photos',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: true,
        ),
        Message(
          id: '2',
          senderId: profile?.userId ?? 'unknown',
          receiverId: 'me',
          content: 'Hey! Thanks for the like 😊',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          isRead: false,
        ),
      ];
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final profile = widget.match.otherUserProfile;
    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'me',
          receiverId: profile?.userId ?? 'unknown',
          content: _messageController.text,
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.match.otherUserProfile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                profile?.photoUrls.isNotEmpty == true
                    ? profile!.photoUrls.first
                    : 'https://picsum.photos/400/600?random=1',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.firstName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Active now',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Voice call
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == 'me';

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.pink : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.pink,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
