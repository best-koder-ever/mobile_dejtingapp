import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/wizard_models.dart';

enum PhotoPrivacyLevel { public, private, matchOnly, vip }

extension PhotoPrivacyLevelExtension on PhotoPrivacyLevel {
  String get displayName {
    switch (this) {
      case PhotoPrivacyLevel.public:
        return 'Public';
      case PhotoPrivacyLevel.private:
        return 'Private';
      case PhotoPrivacyLevel.matchOnly:
        return 'Match Only';
      case PhotoPrivacyLevel.vip:
        return 'VIP';
    }
  }

  String get description {
    switch (this) {
      case PhotoPrivacyLevel.public:
        return 'Visible to everyone';
      case PhotoPrivacyLevel.private:
        return 'Blurred until match';
      case PhotoPrivacyLevel.matchOnly:
        return 'Hidden until match';
      case PhotoPrivacyLevel.vip:
        return 'Premium privacy features';
    }
  }

  String get serverValue {
    return displayName.toUpperCase().replaceAll(' ', '_');
  }
}

class PhotoItem {
  final String url;
  PhotoPrivacyLevel privacyLevel;
  double blurIntensity;

  PhotoItem({
    required this.url,
    this.privacyLevel = PhotoPrivacyLevel.public,
    this.blurIntensity = 0.8,
  });
}

/// Wizard Step 3: Photo upload with privacy controls
/// Matches backend: PATCH /api/wizard/step/3 + POST /api/photos/privacy
class PhotosStep extends StatefulWidget {
  final WizardStepPhotosDto? initialData;
  final Function(WizardStepPhotosDto) onDataChanged;

  const PhotosStep({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<PhotosStep> createState() => _PhotosStepState();
}

class _PhotosStepState extends State<PhotosStep> {
  final List<PhotoItem> _photos = [];
  final int _maxPhotos = 6;
  final int _minPhotos = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _photos.addAll(
        widget.initialData!.photoUrls.map(
          (url) => PhotoItem(url: url),
        ),
      );
    }
    _notifyParent();
  }

  void _notifyParent() {
    if (_photos.length >= _minPhotos) {
      final dto = WizardStepPhotosDto(
        photoUrls: _photos.map((p) => p.url).toList(),
      );
      widget.onDataChanged(dto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Icon(Icons.photo_camera, size: 72, color: Colors.pink[300]),
                const SizedBox(height: 16),
                const Text(
                  'Add Your Photos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload at least $_minPhotos photo (up to $_maxPhotos)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Photo grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: _photos.length < _maxPhotos ? _photos.length + 1 : _photos.length,
            itemBuilder: (context, index) {
              if (index == _photos.length && _photos.length < _maxPhotos) {
                return _buildAddPhotoButton();
              }
              return _buildPhotoCard(_photos[index], index);
            },
          ),
          const SizedBox(height: 24),

          // Progress indicator
          if (_photos.isNotEmpty) ...[
            LinearProgressIndicator(
              value: _photos.length / _maxPhotos,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${_photos.length} of $_maxPhotos photos uploaded',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Privacy info card
          if (_photos.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined, color: Colors.purple[700]),
                      const SizedBox(width: 12),
                      Text(
                        'Privacy Controls',
                        style: TextStyle(
                          color: Colors.purple[900],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap any photo to set privacy level:\n'
                    '• Public: Visible to everyone\n'
                    '• Private: Blurred until match\n'
                    '• Match Only: Hidden until match\n'
                    '• VIP: Premium privacy features',
                    style: TextStyle(
                      color: Colors.purple[800],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: _pickPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[500]),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(PhotoItem photo, int index) {
    return GestureDetector(
      onTap: () => _showPhotoOptions(photo, index),
      child: Stack(
        children: [
          // Photo preview
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(photo.url), // TODO: Use proper image provider
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Privacy badge
          if (photo.privacyLevel != PhotoPrivacyLevel.public)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 12,
                      color: _getPrivacyColor(photo.privacyLevel),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      photo.privacyLevel.displayName,
                      style: TextStyle(
                        color: _getPrivacyColor(photo.privacyLevel),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Primary badge
          if (index == 0)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink[400]!.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Primary Photo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPrivacyColor(PhotoPrivacyLevel level) {
    switch (level) {
      case PhotoPrivacyLevel.public:
        return Colors.green;
      case PhotoPrivacyLevel.private:
        return Colors.orange;
      case PhotoPrivacyLevel.matchOnly:
        return Colors.red;
      case PhotoPrivacyLevel.vip:
        return Colors.purple;
    }
  }

  Future<void> _pickPhoto() async {
    // TODO: Implement actual photo picker
    // For now, add a mock photo for testing
    setState(() {
      _photos.add(PhotoItem(
        url: 'https://via.placeholder.com/300x400?text=Photo+${_photos.length + 1}',
      ));
    });
    _notifyParent();
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
    _notifyParent();
  }

  void _showPhotoOptions(PhotoItem photo, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Photo Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Privacy Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...PhotoPrivacyLevel.values.map((level) {
              final isSelected = photo.privacyLevel == level;
              return ListTile(
                leading: Icon(
                  Icons.circle,
                  size: 12,
                  color: _getPrivacyColor(level),
                ),
                title: Text(level.displayName),
                subtitle: Text(level.description),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.pink) : null,
                selected: isSelected,
                onTap: () {
                  setState(() {
                    photo.privacyLevel = level;
                  });
                  _notifyParent();
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
            // Blur intensity slider (for Private/VIP levels)
            if (photo.privacyLevel == PhotoPrivacyLevel.private ||
                photo.privacyLevel == PhotoPrivacyLevel.vip) ...[
              const Text(
                'Blur Intensity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: photo.blurIntensity,
                min: 0.3,
                max: 1.0,
                divisions: 14,
                activeColor: Colors.pink[400],
                label: '${(photo.blurIntensity * 100).round()}%',
                onChanged: (value) {
                  setState(() {
                    photo.blurIntensity = value;
                  });
                  _notifyParent();
                },
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
