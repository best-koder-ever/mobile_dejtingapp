import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'models.dart';
import 'api_services.dart';
import 'services/photo_service.dart' as photo_api;
import 'utils/profile_completion_calculator.dart';
import 'components/photo_grid_card.dart';

class EnhancedProfileScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final bool isFirstTime;
  final photo_api.PhotoService? photoService;

  const EnhancedProfileScreen({
    super.key,
    this.userProfile,
    this.isFirstTime = false,
    this.photoService,
  });

  @override
  _EnhancedProfileScreenState createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late final photo_api.PhotoService _photoService;

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedEducation;
  String? _selectedGender;
  String? _selectedLookingFor;
  String? _selectedRelationshipType;
  String? _selectedDrinking;
  String? _selectedSmoking;
  String? _selectedWorkout;
  List<String> _interests = [];
  List<String> _languages = [];
  List<String> _photoUrls = [];
  List<_PhotoSlot> _photoSlots = [];
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  int _profileCompletionPercentage = 0;
  int? _uploadingIndex;
  Map<String, String>? _imageHeaders;

  // Options for dropdowns
  final List<String> _educationOptions = [
    'High School',
    'Some College',
    'Undergraduate Degree',
    'Graduate Degree',
    'PhD',
    'Trade School',
    'Prefer not to say',
  ];

  final List<String> _genderOptions = [
    'Woman',
    'Man',
    'Non-binary',
    'Prefer not to say',
  ];

  final List<String> _lookingForOptions = ['Women', 'Men', 'Everyone'];

  final List<String> _relationshipTypeOptions = [
    'Long-term partner',
    'Long-term, open to short',
    'Short-term, open to long',
    'Short-term fun',
    'New friends',
    'Still figuring it out',
  ];

  final List<String> _drinkingOptions = [
    'Not for me',
    'Sober',
    'Sober curious',
    'On special occasions',
    'Socially on weekends',
    'Most nights',
  ];

  final List<String> _smokingOptions = [
    'Non-smoker',
    'Smoker when drinking',
    'Social smoker',
    'Regular smoker',
    'Trying to quit',
  ];

  final List<String> _workoutOptions = [
    'Every day',
    'Often',
    'Sometimes',
    'Never',
  ];

  final List<String> _availableInterests = [
    'Photography',
    'Cooking',
    'Travel',
    'Music',
    'Movies',
    'Reading',
    'Fitness',
    'Yoga',
    'Dancing',
    'Art',
    'Gaming',
    'Sports',
    'Hiking',
    'Swimming',
    'Running',
    'Cycling',
    'Tennis',
    'Soccer',
    'Basketball',
    'Volleyball',
    'Climbing',
    'Skiing',
    'Surfing',
    'Fashion',
    'Shopping',
    'Beauty',
    'Makeup',
    'Skincare',
    'Technology',
    'Coding',
    'Science',
    'Nature',
    'Animals',
    'Dogs',
    'Cats',
    'Coffee',
    'Tea',
    'Wine',
    'Beer',
    'Food',
    'Vegan',
    'Vegetarian',
    'Politics',
    'Activism',
    'Volunteering',
    'Spirituality',
    'Meditation',
    'Writing',
    'Blogging',
    'Podcasts',
    'Stand-up comedy',
    'Theater',
    'Concerts',
    'Festivals',
    'Board games',
    'Trivia',
    'Karaoke',
    'Comedy shows',
  ];

  final List<String> _languageOptions = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Russian',
    'Hindi',
    'Dutch',
    'Swedish',
    'Norwegian',
    'Danish',
    'Polish',
    'Greek',
  ];

  @override
  void initState() {
    super.initState();
    _photoService = widget.photoService ?? photo_api.PhotoService();
    _isEditing = widget.isFirstTime || widget.userProfile == null;
    _loadProfile();
    _fetchPhotosFromService();
    _calculateProfileCompletion();
  }

  void _loadProfile() {
    if (widget.userProfile != null) {
      final profile = widget.userProfile!;
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _bioController.text = profile.bio ?? '';
      _cityController.text = profile.city ?? '';
      _occupationController.text = profile.occupation ?? '';
      _heightController.text = profile.height?.toString() ?? '';
      _selectedDate = profile.dateOfBirth;
      _selectedEducation = profile.education;
      _interests = List.from(profile.interests);
      final initialSlots = List.generate(
        profile.photoUrls.length,
        (index) => _PhotoSlot(
          id: null,
          url: profile.photoUrls[index],
          displayOrder: index + 1,
          isPrimary: index == 0,
        ),
      );
      _updatePhotoState(initialSlots);

      // Load additional fields if available
      _selectedGender = profile.gender;
      _selectedLookingFor = profile.preferences;
      _selectedRelationshipType = profile.relationshipGoals;
      _selectedDrinking = profile.drinking;
      _selectedSmoking = profile.smoking;
      _selectedWorkout = profile.workout;
      _languages = List.from(profile.languages);
    }
  }

  void _calculateProfileCompletion() {
    setState(() {
      _profileCompletionPercentage =
          ProfileCompletionCalculator.calculateProfileCompletion(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        bio: _bioController.text,
        photoUrls: _photoUrls,
        interests: _interests,
        city: _cityController.text,
        occupation: _occupationController.text,
        education: _selectedEducation,
        gender: _selectedGender,
        lookingFor: _selectedLookingFor,
        relationshipType: _selectedRelationshipType,
        drinking: _selectedDrinking,
        smoking: _selectedSmoking,
        workout: _selectedWorkout,
        height: _heightController.text,
        languages: _languages,
      );
    });
  }

  Future<void> _fetchPhotosFromService() async {
    try {
      final token = await userApi.getAuthToken();
      if (token == null) {
        return;
      }

      final summary = await _photoService.getUserPhotos(authToken: token);
      if (!mounted) return;
      setState(() {
        _imageHeaders = {'Authorization': 'Bearer $token'};

        if (summary != null) {
          final photos = List<photo_api.PhotoResponse>.from(summary.photos);
          photos.sort((a, b) {
            if (a.isPrimary != b.isPrimary) {
              return a.isPrimary ? -1 : 1;
            }
            return a.displayOrder.compareTo(b.displayOrder);
          });

          final slots = photos
              .map(
                (photo) => _PhotoSlot(
                  id: photo.id,
                  url: _preferredPhotoUrl(photo.urls),
                  displayOrder: photo.displayOrder,
                  isPrimary: photo.isPrimary,
                ),
              )
              .toList();
          _updatePhotoState(slots);
        }
      });

      if (summary != null) {
        _calculateProfileCompletion();
      }
    } catch (e) {
      debugPrint('Failed to load photos: $e');
    }
  }

  String _preferredPhotoUrl(photo_api.PhotoUrls urls) {
    if (urls.medium.isNotEmpty) {
      return urls.medium;
    }
    if (urls.thumbnail.isNotEmpty) {
      return urls.thumbnail;
    }
    return urls.full;
  }

  void _updatePhotoState(List<_PhotoSlot> slots) {
    slots.sort(_photoSlotComparator);
    _photoSlots = List<_PhotoSlot>.generate(
      slots.length,
      (index) => slots[index].copyWith(displayOrder: index + 1),
    );
    if (!_photoSlots.any((slot) => slot.isPrimary) && _photoSlots.isNotEmpty) {
      _photoSlots = _photoSlots
          .asMap()
          .entries
          .map(
            (entry) => entry.value.copyWith(
              isPrimary: entry.key == 0,
            ),
          )
          .toList();
    }
    _photoUrls = _photoSlots.map((slot) => slot.url).toList();
  }

  int _photoSlotComparator(_PhotoSlot a, _PhotoSlot b) {
    if (a.isPrimary != b.isPrimary) {
      return a.isPrimary ? -1 : 1;
    }
    return a.displayOrder.compareTo(b.displayOrder);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1995),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _calculateProfileCompletion();
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_interests.contains(interest)) {
        _interests.remove(interest);
      } else if (_interests.length < 10) {
        _interests.add(interest);
      }
    });
    _calculateProfileCompletion();
  }

  void _toggleLanguage(String language) {
    setState(() {
      if (_languages.contains(language)) {
        _languages.remove(language);
      } else if (_languages.length < 5) {
        _languages.add(language);
      }
    });
    _calculateProfileCompletion();
  }

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (image != null) {
      setState(() {
        _isLoading = true;
        _uploadingIndex = index;
        _errorMessage = null;
      });

      try {
        final token = await userApi.getAuthToken();
        if (token == null) {
          throw Exception('Missing authentication token');
        }

        _imageHeaders = {'Authorization': 'Bearer $token'};

        final result = await _photoService.uploadPhoto(
          imageFile: File(image.path),
          authToken: token,
          isPrimary: _photoSlots.isEmpty || index == 0,
          displayOrder: index + 1,
        );

        if (!result.success || result.photo == null) {
          throw Exception(result.errorMessage ?? 'Unknown upload error');
        }

        final uploadedPhoto = result.photo!;

        setState(() {
          _imageHeaders = {'Authorization': 'Bearer $token'};
          final updatedSlots = List<_PhotoSlot>.from(_photoSlots);
          final newSlot = _PhotoSlot(
            id: uploadedPhoto.id,
            url: _preferredPhotoUrl(uploadedPhoto.urls),
            displayOrder: uploadedPhoto.displayOrder,
            isPrimary: uploadedPhoto.isPrimary,
          );

          if (index < updatedSlots.length) {
            updatedSlots[index] = newSlot;
          } else {
            updatedSlots.add(newSlot);
          }

          _updatePhotoState(updatedSlots);
        });
        _calculateProfileCompletion();

        final message = result.warnings.isNotEmpty
            ? result.warnings.join('\n')
            : 'Photo uploaded successfully!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to upload photo: ${e.toString()}';
        });
      } finally {
        if (!mounted) {
          return;
        }
        setState(() {
          _isLoading = false;
          _uploadingIndex = null;
        });
      }
    }
  }

  Future<void> _removePhoto(int index) async {
    if (index >= _photoSlots.length) {
      return;
    }

    final slot = _photoSlots[index];

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await userApi.getAuthToken();
      if (token == null) {
        throw Exception('Missing authentication token');
      }

      bool success = true;
      if (slot.id != null) {
        success = await _photoService.deletePhoto(
          photoId: slot.id!,
          authToken: token,
        );
      } else {
        await userApi.deletePhoto(slot.url);
      }

      if (!success) {
        throw Exception('Photo service rejected the delete request');
      }

      setState(() {
        final updatedSlots = List<_PhotoSlot>.from(_photoSlots)
          ..removeAt(index);
        for (var i = 0; i < updatedSlots.length; i++) {
          updatedSlots[i] = updatedSlots[i].copyWith(displayOrder: i + 1);
        }
        _updatePhotoState(updatedSlots);
      });
      _calculateProfileCompletion();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete photo: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Please select your birth date';
      });
      return;
    }

    if (_photoUrls.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one photo';
      });
      return;
    }

    if (_interests.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one interest';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = UserProfile(
        id: widget.userProfile?.id,
        userId: widget.userProfile?.userId ?? '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _selectedDate!,
        bio: _bioController.text.trim(),
        city: _cityController.text.trim(),
        occupation: _occupationController.text.trim(),
        interests: _interests,
        height: int.tryParse(_heightController.text.trim()),
        education: _selectedEducation,
        photoUrls: _photoUrls,
        primaryPhotoUrl: _photoUrls.isNotEmpty ? _photoUrls.first : null,
        relationshipGoals: _selectedRelationshipType,
        preferences: _selectedLookingFor,
        gender: _selectedGender,
        drinking: _selectedDrinking,
        smoking: _selectedSmoking,
        workout: _selectedWorkout,
        languages: _languages,
      );

      if (widget.userProfile == null) {
        await userApi.createProfile(profile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile created successfully!')),
          );
          if (widget.isFirstTime) {
            Navigator.of(context).pop();
          }
        }
      } else {
        await userApi.updateProfile(profile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      }

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditing && widget.userProfile != null) {
      return _buildDisplayMode();
    } else {
      return _buildEditMode();
    }
  }

  Widget _buildDisplayMode() {
    final profile = widget.userProfile!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildPhotoGrid(isEditing: false),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile completion if not 100%
                  if (_profileCompletionPercentage < 100) ...[
                    _buildProfileCompletionCard(),
                    const SizedBox(height: 16),
                  ],

                  // Name and basic info
                  Text(
                    '${profile.firstName} ${profile.lastName}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${profile.age} years old',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  if (profile.bio?.isNotEmpty == true) ...[
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(profile.bio!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                  ],

                  // Interests
                  if (profile.interests.isNotEmpty) ...[
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
                      children: profile.interests
                          .map(
                            (interest) => Chip(
                              label: Text(interest),
                              backgroundColor: Colors.pink[100],
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Details
                  _buildDetailsSection(profile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFirstTime ? 'Create Your Profile' : 'Edit Profile',
        ),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile completion card
              _buildProfileCompletionCard(),
              const SizedBox(height: 24),

              // Photos section
              _buildPhotosSection(),
              const SizedBox(height: 24),

              // Basic info section
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // About section
              _buildAboutSection(),
              const SizedBox(height: 24),

              // Lifestyle section
              _buildLifestyleSection(),
              const SizedBox(height: 24),

              // Interests section
              _buildInterestsSection(),
              const SizedBox(height: 24),

              // Languages section
              _buildLanguagesSection(),
              const SizedBox(height: 32),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isFirstTime
                              ? 'Create Profile'
                              : 'Save Changes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // Cancel button (for editing)
              if (!widget.isFirstTime && widget.userProfile != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _loadProfile();
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCompletionCard() {
    Color progressColor = ProfileCompletionCalculator.getCompletionColor(
      _profileCompletionPercentage,
    );
    String message = ProfileCompletionCalculator.getProfileCompletionMessage(
      _profileCompletionPercentage,
    );
    String matchBonus = ProfileCompletionCalculator.getMatchQualityBonus(
      _profileCompletionPercentage,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink[50]!, Colors.pink[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: Colors.pink[400]),
              const SizedBox(width: 8),
              Text(
                'Profile Strength: $_profileCompletionPercentage%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _profileCompletionPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            matchBonus,
            style: TextStyle(
              fontSize: 12,
              color: Colors.pink[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_camera, color: Colors.pink[400]),
            const SizedBox(width: 8),
            const Text(
              'Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${_photoUrls.length}/9',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Add at least 2 photos. First photo will be your main photo.',
        ),
        const SizedBox(height: 16),
        _buildPhotoGrid(isEditing: true),
      ],
    );
  }

  Widget _buildPhotoGrid({required bool isEditing}) {
    final photos = _photoSlots;
    final itemCount = isEditing ? 9 : photos.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < photos.length) {
          final slot = photos[index];
          return PhotoGridCard(
            photoUrl: slot.url,
            isMainPhoto: slot.isPrimary || index == 0,
            isEditing: isEditing,
            onDelete: isEditing ? () => _removePhoto(index) : null,
            onTap: isEditing ? () => _pickImage(index) : null,
            imageHeaders: _imageHeaders,
          );
        } else if (isEditing) {
          return PhotoGridCard(
            isEditing: true,
            onTap: () => _pickImage(index),
            isLoading: _isLoading && _uploadingIndex == index,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, color: Colors.pink[400]),
            const SizedBox(width: 8),
            const Text(
              'About Me',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'Bio (50+ characters recommended)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            helperText:
                'Tell people about yourself, your interests, what makes you unique!',
          ),
          maxLines: 4,
          maxLength: 500,
          onChanged: (_) => _calculateProfileCompletion(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _calculateProfileCompletion(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateProfileCompletion(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _occupationController,
          decoration: const InputDecoration(
            labelText: 'Job Title',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _calculateProfileCompletion(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _schoolController,
          decoration: const InputDecoration(
            labelText: 'School',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _calculateProfileCompletion(),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedEducation,
          decoration: const InputDecoration(
            labelText: 'Education',
            border: OutlineInputBorder(),
          ),
          items: _educationOptions
              .map(
                (education) => DropdownMenuItem(
                  value: education,
                  child: Text(education),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedEducation = value);
            _calculateProfileCompletion();
          },
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite_border, color: Colors.pink[400]),
            const SizedBox(width: 8),
            const Text(
              'Lifestyle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedRelationshipType,
          decoration: const InputDecoration(
            labelText: 'Looking for',
            border: OutlineInputBorder(),
          ),
          items: _relationshipTypeOptions
              .map(
                (type) => DropdownMenuItem(value: type, child: Text(type)),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedRelationshipType = value);
            _calculateProfileCompletion();
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedDrinking,
          decoration: const InputDecoration(
            labelText: 'Drinking',
            border: OutlineInputBorder(),
          ),
          items: _drinkingOptions
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedDrinking = value);
            _calculateProfileCompletion();
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedSmoking,
          decoration: const InputDecoration(
            labelText: 'Smoking',
            border: OutlineInputBorder(),
          ),
          items: _smokingOptions
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedSmoking = value);
            _calculateProfileCompletion();
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedWorkout,
          decoration: const InputDecoration(
            labelText: 'Workout',
            border: OutlineInputBorder(),
          ),
          items: _workoutOptions
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedWorkout = value);
            _calculateProfileCompletion();
          },
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite, color: Colors.pink[400]),
            const SizedBox(width: 8),
            const Text(
              'Interests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${_interests.length}/10',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Choose interests to show on your profile'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableInterests.map((interest) {
            final isSelected = _interests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) => _toggleInterest(interest),
              selectedColor: Colors.pink[200],
              checkmarkColor: Colors.pink[800],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.language, color: Colors.pink[400]),
            const SizedBox(width: 8),
            const Text(
              'Languages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${_languages.length}/5',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Select languages you speak'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _languageOptions.map((language) {
            final isSelected = _languages.contains(language);
            return FilterChip(
              label: Text(language),
              selected: isSelected,
              onSelected: (selected) => _toggleLanguage(language),
              selectedColor: Colors.blue[200],
              checkmarkColor: Colors.blue[800],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (profile.occupation?.isNotEmpty == true)
          _buildDetailRow(Icons.work, 'Job', profile.occupation!),
        if (profile.education?.isNotEmpty == true)
          _buildDetailRow(Icons.school, 'Education', profile.education!),
        if (profile.height != null)
          _buildDetailRow(Icons.height, 'Height', '${profile.height} cm'),
        if (profile.city?.isNotEmpty == true)
          _buildDetailRow(Icons.location_on, 'Lives in', profile.city!),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_camera, color: Colors.pink[400]),
            const SizedBox(width: 8),
            const Text(
              'Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${_photoUrls.length}/9',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Add at least 2 photos. First photo will be your main photo.',
        ),
        const SizedBox(height: 16),
        _buildPhotoGrid(isEditing: true),
      ],
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _occupationController.dispose();
    _heightController.dispose();
    _schoolController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }
}

class _PhotoSlot {
  final int? id;
  final String url;
  final int displayOrder;
  final bool isPrimary;

  const _PhotoSlot({
    this.id,
    required this.url,
    required this.displayOrder,
    this.isPrimary = false,
  });

  _PhotoSlot copyWith({
    int? id,
    String? url,
    int? displayOrder,
    bool? isPrimary,
  }) {
    return _PhotoSlot(
      id: id ?? this.id,
      url: url ?? this.url,
      displayOrder: displayOrder ?? this.displayOrder,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
