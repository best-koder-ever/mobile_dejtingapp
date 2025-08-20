import 'package:flutter/material.dart';
import 'models.dart';
import 'api_services.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final bool isFirstTime;

  const ProfileScreen({super.key, this.userProfile, this.isFirstTime = false});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedEducation;
  String? _selectedLifestyle;
  String? _selectedRelationshipGoals;
  List<String> _interests = [];
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;

  final List<String> _educationOptions = [
    'High School',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Trade School',
    'Other',
  ];

  final List<String> _lifestyleOptions = [
    'Active',
    'Relaxed',
    'Social',
    'Homebody',
    'Adventurous',
    'Creative',
    'Professional',
  ];

  final List<String> _relationshipGoalsOptions = [
    'Casual Dating',
    'Long Term',
    'Marriage',
    'Just Friends',
    'Not Sure',
  ];

  final List<String> _availableInterests = [
    'Reading',
    'Travel',
    'Sports',
    'Music',
    'Movies',
    'Cooking',
    'Fitness',
    'Art',
    'Photography',
    'Gaming',
    'Dancing',
    'Hiking',
    'Technology',
    'Fashion',
    'Food',
    'Pets',
    'Yoga',
    'Swimming',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isFirstTime || widget.userProfile == null;
    _loadProfile();
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
      _selectedLifestyle = profile.lifestyle;
      _selectedRelationshipGoals = profile.relationshipGoals;
      _interests = List.from(profile.interests);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // 18+ only
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_interests.contains(interest)) {
        _interests.remove(interest);
      } else if (_interests.length < 8) {
        // Limit to 8 interests
        _interests.add(interest);
      }
    });
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
        userId: widget.userProfile?.userId ?? '', // Will be set by backend
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _selectedDate!,
        bio: _bioController.text.trim(),
        city: _cityController.text.trim(),
        occupation: _occupationController.text.trim(),
        interests: _interests,
        height: int.tryParse(_heightController.text.trim()),
        education: _selectedEducation,
        lifestyle: _selectedLifestyle,
        relationshipGoals: _selectedRelationshipGoals,
      );

      if (widget.userProfile == null) {
        // Create new profile
        await userApi.createProfile(profile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile created successfully!')),
          );
          // If this was first time setup, we need to refresh the parent
          if (widget.isFirstTime) {
            Navigator.of(
              context,
            ).pop(); // This will trigger refresh in HomeScreen
          }
        }
      } else {
        // Update existing profile
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
      // Display mode
      return _buildDisplayMode();
    } else {
      // Edit/Create mode
      return _buildEditMode();
    }
  }

  Widget _buildDisplayMode() {
    final profile = widget.userProfile!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.pink[100],
                  backgroundImage:
                      profile.primaryPhotoUrl != null
                          ? NetworkImage(profile.primaryPhotoUrl!)
                          : null,
                  child:
                      profile.primaryPhotoUrl == null
                          ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.pink[400],
                          )
                          : null,
                ),
                const SizedBox(height: 16),
                Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${profile.age} years old',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                if (profile.city != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      Text(
                        profile.city!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(profile.bio!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
          ],

          // Interests
          if (profile.interests.isNotEmpty) ...[
            const Text(
              'Interests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  profile.interests
                      .map(
                        (interest) => Chip(
                          label: Text(interest),
                          backgroundColor: Colors.pink[100],
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Details
          const Text(
            'Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Occupation', profile.occupation),
          _buildDetailRow('Education', profile.education),
          _buildDetailRow(
            'Height',
            profile.height != null ? '${profile.height} cm' : null,
          ),
          _buildDetailRow('Lifestyle', profile.lifestyle),
          _buildDetailRow('Looking for', profile.relationshipGoals),

          const SizedBox(height: 32),

          // Edit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isFirstTime ? 'Create Your Profile' : 'Edit Profile',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // First Name
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Birth Date
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select Birth Date *',
                      style: TextStyle(
                        color:
                            _selectedDate != null
                                ? Colors.black
                                : Colors.grey[600],
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'About You',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // City
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Occupation
            TextFormField(
              controller: _occupationController,
              decoration: const InputDecoration(
                labelText: 'Occupation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Height
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Education
            DropdownButtonFormField<String>(
              value: _selectedEducation,
              decoration: const InputDecoration(
                labelText: 'Education',
                border: OutlineInputBorder(),
              ),
              items:
                  _educationOptions
                      .map(
                        (education) => DropdownMenuItem(
                          value: education,
                          child: Text(education),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedEducation = value),
            ),
            const SizedBox(height: 16),

            // Lifestyle
            DropdownButtonFormField<String>(
              value: _selectedLifestyle,
              decoration: const InputDecoration(
                labelText: 'Lifestyle',
                border: OutlineInputBorder(),
              ),
              items:
                  _lifestyleOptions
                      .map(
                        (lifestyle) => DropdownMenuItem(
                          value: lifestyle,
                          child: Text(lifestyle),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedLifestyle = value),
            ),
            const SizedBox(height: 16),

            // Relationship Goals
            DropdownButtonFormField<String>(
              value: _selectedRelationshipGoals,
              decoration: const InputDecoration(
                labelText: 'Looking For',
                border: OutlineInputBorder(),
              ),
              items:
                  _relationshipGoalsOptions
                      .map(
                        (goal) =>
                            DropdownMenuItem(value: goal, child: Text(goal)),
                      )
                      .toList(),
              onChanged:
                  (value) => setState(() => _selectedRelationshipGoals = value),
            ),
            const SizedBox(height: 24),

            // Interests
            const Text(
              'Interests (Select up to 8)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _availableInterests.map((interest) {
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

            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null) ...[
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
            ],

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          widget.isFirstTime
                              ? 'Create Profile'
                              : 'Save Changes',
                        ),
              ),
            ),

            // Cancel Button (only for editing existing profile)
            if (!widget.isFirstTime && widget.userProfile != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _loadProfile(); // Reset form
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ],
        ),
      ),
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
    super.dispose();
  }
}
