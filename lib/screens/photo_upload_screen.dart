import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/photo_service.dart';

class PhotoUploadScreen extends StatefulWidget {
  final String authToken;
  final int userId;
  final Function(bool isComplete) onPhotoRequirementMet;

  const PhotoUploadScreen({
    Key? key,
    required this.authToken,
    required this.userId,
    required this.onPhotoRequirementMet,
  }) : super(key: key);

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final PhotoService _photoService = PhotoService();
  final ImagePicker _picker = ImagePicker();

  List<PhotoSlot> photoSlots = [];
  bool isLoading = false;
  String? statusMessage;

  static const int minPhotos = 4;
  static const int maxPhotos = 6;

  @override
  void initState() {
    super.initState();
    _initializePhotoSlots();
    _loadExistingPhotos();
  }

  void _initializePhotoSlots() {
    photoSlots = List.generate(
      maxPhotos,
      (index) => PhotoSlot(
        index: index,
        isEmpty: true,
        isPrimary: index == 0, // First slot is primary by default
      ),
    );
  }

  Future<void> _loadExistingPhotos() async {
    setState(() => isLoading = true);

    try {
      final userPhotos = await _photoService.getUserPhotos(
        authToken: widget.authToken,
        userId: widget.userId,
      );

      if (userPhotos != null) {
        setState(() {
          // Update slots with existing photos
          for (int i = 0; i < userPhotos.photos.length && i < maxPhotos; i++) {
            final photo = userPhotos.photos[i];
            photoSlots[i] = PhotoSlot(
              index: i,
              isEmpty: false,
              photoResponse: photo,
              isPrimary: photo.isPrimary,
            );
          }
          _checkPhotoRequirements();
        });
      }
    } catch (e) {
      _showStatusMessage('Failed to load existing photos: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  int get uploadedPhotosCount => photoSlots
      .where((slot) => !slot.isEmpty || slot.localFile != null)
      .length;
  bool get meetsMinimumRequirement => uploadedPhotosCount >= minPhotos;
  bool get hasReachedMaximum => uploadedPhotosCount >= maxPhotos;

  void _checkPhotoRequirements() {
    widget.onPhotoRequirementMet(meetsMinimumRequirement);
  }

  Future<void> _pickPhoto(int slotIndex) async {
    try {
      // Show photo source selection
      final source = await _showPhotoSourceDialog();
      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        final imageFile = File(image.path);

        // Immediately show the picked image locally
        setState(() {
          photoSlots[slotIndex] = PhotoSlot(
            index: slotIndex,
            isEmpty: false,
            isPrimary: photoSlots[slotIndex].isPrimary,
            localFile: imageFile, // Show locally first
          );
        });

        // Then upload in the background
        await _uploadPhoto(imageFile, slotIndex);
      }
    } catch (e) {
      _showStatusMessage('Failed to pick photo: $e');
    }
  }

  Future<ImageSource?> _showPhotoSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Photo Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadPhoto(File imageFile, int slotIndex) async {
    setState(() {
      isLoading = true;
      statusMessage = 'Uploading photo...';
    });

    try {
      final result = await _photoService.uploadPhoto(
        imageFile: imageFile,
        authToken: widget.authToken,
        isPrimary: photoSlots[slotIndex].isPrimary,
        displayOrder: slotIndex + 1,
      );

      if (result.success && result.photo != null) {
        setState(() {
          photoSlots[slotIndex] = PhotoSlot(
            index: slotIndex,
            isEmpty: false,
            photoResponse: result.photo!,
            isPrimary: result.photo!.isPrimary,
            localFile: null, // Clear local file after successful upload
          );
          _checkPhotoRequirements();
        });

        _showStatusMessage(
          'Photo uploaded successfully! ${result.processingInfo?.wasResized == true ? '(Resized for optimization)' : ''}',
          isError: false,
        );
      } else {
        // Keep the local file if upload fails
        _showStatusMessage(
            'Upload failed: ${result.errorMessage}. Photo kept locally for now.');
      }
    } catch (e) {
      // Keep the local file if upload fails
      _showStatusMessage('Upload failed: $e. Photo kept locally for now.');
      print('Photo upload error: $e'); // Debug log
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deletePhoto(int slotIndex) async {
    final photoSlot = photoSlots[slotIndex];
    if (photoSlot.isEmpty && photoSlot.localFile == null) return;

    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() => isLoading = true);

    try {
      // If it's just a local file, delete immediately
      if (photoSlot.localFile != null && photoSlot.photoResponse == null) {
        setState(() {
          photoSlots[slotIndex] = PhotoSlot(
            index: slotIndex,
            isEmpty: true,
            isPrimary: slotIndex == 0,
          );
          _checkPhotoRequirements();
        });
        _showStatusMessage('Local photo removed', isError: false);
        return;
      }

      // If it's an uploaded photo, delete from server
      if (photoSlot.photoResponse != null) {
        final success = await _photoService.deletePhoto(
          photoId: photoSlot.photoResponse!.id,
          authToken: widget.authToken,
        );

        if (success) {
          setState(() {
            photoSlots[slotIndex] = PhotoSlot(
              index: slotIndex,
              isEmpty: true,
              isPrimary: slotIndex == 0,
            );
            _checkPhotoRequirements();
          });
          _showStatusMessage('Photo deleted successfully', isError: false);
        } else {
          _showStatusMessage(
              'Failed to delete photo from server, but keeping local copy');
        }
      }
    } catch (e) {
      _showStatusMessage('Delete failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Photo'),
            content: const Text('Are you sure you want to delete this photo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showStatusMessage(String message, {bool isError = true}) {
    setState(() => statusMessage = message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Clear status message after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => statusMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Photos'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator and requirements
          _buildRequirementsHeader(),

          // Photo grid
          Expanded(
            child: _buildPhotoGrid(),
          ),

          // Guidelines and tips
          _buildPhotoGuidelines(),

          // Status message
          if (statusMessage != null) _buildStatusMessage(),
        ],
      ),
    );
  }

  Widget _buildRequirementsHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: meetsMinimumRequirement
            ? Colors.green.shade50
            : Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(
            color: meetsMinimumRequirement ? Colors.green : Colors.orange,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                meetsMinimumRequirement
                    ? Icons.check_circle
                    : Icons.photo_camera,
                color: meetsMinimumRequirement ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meetsMinimumRequirement
                          ? '✅ Photo requirements met!'
                          : '📸 Add $minPhotos-$maxPhotos photos to continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: meetsMinimumRequirement
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$uploadedPhotosCount/$maxPhotos photos uploaded',
                      style: TextStyle(
                        fontSize: 14,
                        color: meetsMinimumRequirement
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: uploadedPhotosCount / maxPhotos,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              meetsMinimumRequirement ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: maxPhotos,
        itemBuilder: (context, index) => _buildPhotoSlot(index),
      ),
    );
  }

  Widget _buildPhotoSlot(int index) {
    final slot = photoSlots[index];

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              if (slot.isEmpty && slot.localFile == null) {
                _pickPhoto(index);
              } else {
                _showPhotoOptions(index);
              }
            },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: slot.isPrimary ? Colors.pink : Colors.grey.shade300,
            width: slot.isPrimary ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            children: [
              // Photo or placeholder
              if (slot.isEmpty && slot.localFile == null)
                _buildEmptySlot(index)
              else
                _buildPhotoSlotContent(slot),

              // Primary badge
              if (slot.isPrimary)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 12),
                        SizedBox(width: 2),
                        Text(
                          'Primary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Loading overlay
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySlot(int index) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            index == 0 ? 'Primary Photo' : 'Photo ${index + 1}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (index < minPhotos)
            Text(
              'Required',
              style: TextStyle(
                color: Colors.orange.shade600,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlotContent(PhotoSlot slot) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo image - show local file first, then network image
        if (slot.localFile != null)
          // Show local file immediately
          Image.file(
            slot.localFile!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey.shade600),
                  const SizedBox(height: 4),
                  Text(
                    'Local Image Error',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (slot.photoResponse != null)
          // Show network image after upload
          CachedNetworkImage(
            imageUrl: slot.photoResponse!.urls.medium.isNotEmpty
                ? slot.photoResponse!.urls.medium
                : slot.photoResponse!.urls.full,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey.shade600),
                  const SizedBox(height: 4),
                  Text(
                    'Network Image Error',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Photo info overlay (only show for uploaded photos)
        if (slot.photoResponse != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.photoResponse!.fileSizeFormatted,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${slot.photoResponse!.width}×${slot.photoResponse!.height}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (slot.localFile != null)
          // Show "uploading" indicator for local files
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.orange.withOpacity(0.7),
                  ],
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Uploading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showPhotoOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Replace Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(index);
              },
            ),
            if (index != 0) // Don't allow deleting primary photo easily
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Set as Primary'),
                onTap: () {
                  Navigator.pop(context);
                  _setPrimaryPhoto(index);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Photo',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePhoto(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setPrimaryPhoto(int slotIndex) async {
    final photoSlot = photoSlots[slotIndex];
    if (photoSlot.isEmpty || photoSlot.photoResponse == null) return;

    setState(() => isLoading = true);

    try {
      // Update the photo to be primary
      final updatedPhoto = await _photoService.updatePhoto(
        photoId: photoSlot.photoResponse!.id,
        authToken: widget.authToken,
        isPrimary: true,
      );

      if (updatedPhoto != null) {
        setState(() {
          // Update all slots to reflect new primary photo
          for (int i = 0; i < photoSlots.length; i++) {
            if (i == slotIndex) {
              photoSlots[i] = PhotoSlot(
                index: i,
                isEmpty: false,
                photoResponse: updatedPhoto,
                isPrimary: true,
              );
            } else if (!photoSlots[i].isEmpty) {
              photoSlots[i] = PhotoSlot(
                index: i,
                isEmpty: false,
                photoResponse: photoSlots[i].photoResponse!,
                isPrimary: false,
              );
            }
          }
        });
        _showStatusMessage('Primary photo updated successfully',
            isError: false);
      } else {
        _showStatusMessage('Failed to set primary photo');
      }
    } catch (e) {
      _showStatusMessage('Failed to set primary photo: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildPhotoGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          top: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Photo Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Use clear, high-quality photos\n'
            '• Make sure your face is visible\n'
            '• Avoid group photos as your primary\n'
            '• Show your personality and interests\n'
            '• Keep it recent and authentic',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade100,
      child: Text(
        statusMessage!,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

/// Photo slot data class
class PhotoSlot {
  final int index;
  final bool isEmpty;
  final PhotoResponse? photoResponse;
  final bool isPrimary;
  final File? localFile; // Add local file for immediate display

  PhotoSlot({
    required this.index,
    required this.isEmpty,
    this.photoResponse,
    required this.isPrimary,
    this.localFile,
  });
}
