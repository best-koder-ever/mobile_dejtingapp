import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/demo_service.dart';
import '../config/environment.dart';

/// REAL Photo Upload Screen - No simulation, actual file upload!
class RealPhotoUploadScreen extends StatefulWidget {
  @override
  State<RealPhotoUploadScreen> createState() => _RealPhotoUploadScreenState();
}

class _RealPhotoUploadScreenState extends State<RealPhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<String> _logs = [];
  final List<UploadedPhoto> _photos = [];

  String? _authToken;
  int? _userId;
  bool _isInitialized = false;
  bool _isUploading = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} | $message');
    });
    if (kDebugMode) print(message);
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  final ScrollController _scrollController = ScrollController();

  Future<void> _initializeAuth() async {
    _addLog('🔐 Initializing authentication...');

    try {
      final result =
          await DemoService.loginWithDemoUser('erik.astrom@demo.com');

      if (result.success && result.token != null) {
        setState(() {
          _authToken = result.token;
          _userId = 1; // Demo user ID
          _isInitialized = true;
        });
        _addLog('✅ Authentication successful!');
        _addLog('User: erik.astrom@demo.com (ID: $_userId)');

        // Load existing photos
        await _loadExistingPhotos();
      } else {
        setState(() {
          _initError = 'Login failed: ${result.message}';
        });
        _addLog('❌ Authentication failed: ${result.message}');
      }
    } catch (e) {
      setState(() {
        _initError = 'Authentication error: $e';
      });
      _addLog('❌ Auth error: $e');
    }
  }

  Future<void> _loadExistingPhotos() async {
    _addLog('📱 Loading existing photos...');

    try {
      final response = await http.get(
        Uri.parse(
            '${EnvironmentConfig.settings.photoServiceUrl}/api/photos/user/$_userId'),
        headers: {'Authorization': 'Bearer $_authToken'},
      );

      if (response.statusCode == 200) {
        // Handle the response (might be empty array for new user)
        _addLog('✅ Photos loaded successfully');
        // Parse response if needed
      } else if (response.statusCode == 404) {
        _addLog('📷 No existing photos found (new user)');
      } else {
        _addLog('⚠️  Photo loading returned: ${response.statusCode}');
      }
    } catch (e) {
      _addLog('❌ Error loading photos: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (!_isInitialized) {
      _addLog('❌ Not authenticated yet');
      return;
    }

    setState(() => _isUploading = true);
    _addLog('📸 Opening image picker...');

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        _addLog('📵 No image selected');
        setState(() => _isUploading = false);
        return;
      }

      _addLog('✅ Image selected: ${image.name}');
      _addLog('📊 File size: ${(await image.length())} bytes');

      // Read image as bytes
      final Uint8List imageBytes = await image.readAsBytes();
      _addLog('📦 Image loaded into memory');

      // Upload the image
      await _uploadImageBytes(imageBytes, image.name);
    } catch (e) {
      _addLog('❌ Error picking image: $e');
    }

    setState(() => _isUploading = false);
  }

  Future<void> _uploadImageBytes(Uint8List imageBytes, String filename) async {
    _addLog('🚀 Starting upload to PhotoService...');

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${EnvironmentConfig.settings.photoServiceUrl}/api/photos'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $_authToken';

      // Add the image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'Photo', // This should match the PhotoUploadDto.Photo property
          imageBytes,
          filename: filename,
        ),
      );

      // Add other form data if needed
      request.fields['IsPrimary'] = 'true';
      request.fields['DisplayOrder'] = '1';
      request.fields['Description'] = 'Uploaded via Real Photo Upload';

      _addLog('📡 Sending request to server...');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      _addLog('📨 Server responded: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _addLog('🎉 Upload successful!');
        _addLog('Response: $responseBody');

        // Parse the response to get photo info
        try {
          final photoData = json.decode(responseBody);
          _addLog('📊 Response data keys: ${photoData.keys.toList()}');

          // Try multiple possible URL field names
          String? photoUrl;
          String? thumbUrl;

          // Check if response has nested photo object with urls
          if (photoData['photo'] != null &&
              photoData['photo']['urls'] != null) {
            final urls = photoData['photo']['urls'];
            photoUrl = urls['full'] ?? urls['medium'];
            // Skip thumbnail since it returns 404 - use full image instead
            thumbUrl = photoUrl; // Use same URL for thumbnail
            _addLog('🔗 Found nested URLs - Full: $photoUrl');
            _addLog(
                '📝 Using full URL for thumbnail (thumbnail endpoint returns 404)');
          } else {
            // Fallback to flat structure
            final urlFields = [
              'url',
              'photoUrl',
              'fileUrl',
              'filePath',
              'path'
            ];
            final thumbnailFields = ['thumbnailUrl', 'thumbUrl', 'thumbnail'];

            for (String field in urlFields) {
              if (photoData[field] != null) {
                photoUrl = photoData[field].toString();
                _addLog('🔗 Found photo URL in field "$field": $photoUrl');
                break;
              }
            }

            for (String field in thumbnailFields) {
              if (photoData[field] != null) {
                thumbUrl = photoData[field].toString();
                _addLog('🔗 Found thumbnail URL in field "$field": $thumbUrl');
                break;
              }
            }
          }

          // If URLs are relative, make them absolute
          if (photoUrl != null && !photoUrl.startsWith('http')) {
            photoUrl = 'http://localhost:8085$photoUrl';
            _addLog('🔧 Converted to absolute URL: $photoUrl');
          }

          if (thumbUrl != null && !thumbUrl.startsWith('http')) {
            thumbUrl = 'http://localhost:8085$thumbUrl';
            _addLog('🔧 Converted to absolute thumbnail URL: $thumbUrl');
          }

          final uploadedPhoto = UploadedPhoto(
            id: photoData['photo']?['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            filename: filename,
            uploadTime: DateTime.now(),
            url: photoUrl,
            thumbnailUrl: thumbUrl,
            imageBytes: imageBytes, // Store the original image bytes
          );

          setState(() {
            _photos.add(uploadedPhoto);
          });

          _addLog('📷 Photo added to grid!');
          _addLog('Photo URL: ${uploadedPhoto.url ?? "None"}');
          if (uploadedPhoto.thumbnailUrl != null) {
            _addLog('Thumbnail URL: ${uploadedPhoto.thumbnailUrl}');
          }
        } catch (e) {
          _addLog('⚠️  Upload succeeded but couldn\'t parse response: $e');
          _addLog('Raw response: $responseBody');

          // Add photo anyway with basic info
          setState(() {
            _photos.add(UploadedPhoto(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              filename: filename,
              uploadTime: DateTime.now(),
              url: null,
              thumbnailUrl: null,
            ));
          });
        }
      } else {
        _addLog('❌ Upload failed: ${response.statusCode}');
        _addLog('Error: $responseBody');
      }
    } catch (e) {
      _addLog('❌ Upload error: $e');
    }
  }

  Widget _buildPhotoGrid() {
    if (_photos.isEmpty) {
      return Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No photos uploaded yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                'Upload your first photo to see it here!',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uploaded Photos (${_photos.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(7)),
                          ),
                          child: photo.imageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(7)),
                                  child: Image.memory(
                                    photo.imageBytes!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('❌ Image.memory failed: $error');
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image,
                                              size: 24, color: Colors.red),
                                          SizedBox(height: 4),
                                          Text(
                                            'Memory Error',
                                            style: TextStyle(
                                                fontSize: 8, color: Colors.red),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                )
                              : photo.url != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(7)),
                                      child: Image.network(
                                        photo.thumbnailUrl ?? photo.url!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Don't call _addLog here to avoid setState during build
                                          print(
                                              '❌ Image load failed for URL: ${photo.thumbnailUrl ?? photo.url}');
                                          print('❌ Error: $error');
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.broken_image,
                                                  size: 24, color: Colors.red),
                                              SizedBox(height: 4),
                                              Text(
                                                'Load Failed',
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.red),
                                              ),
                                              Text(
                                                photo.url?.substring(photo
                                                                .url!.length >
                                                            20
                                                        ? photo.url!.length - 20
                                                        : 0) ??
                                                    'No URL',
                                                style: TextStyle(
                                                    fontSize: 6,
                                                    color: Colors.red),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          );
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            // Don't call _addLog here to avoid setState during build
                                            print(
                                                '✅ Image loaded successfully: ${photo.thumbnailUrl ?? photo.url}');
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle,
                                            size: 24, color: Colors.green),
                                        SizedBox(height: 4),
                                        Text(
                                          'Uploaded',
                                          style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.green[800]),
                                        ),
                                        Text(
                                          photo.filename.length > 15
                                              ? '${photo.filename.substring(0, 12)}...'
                                              : photo.filename,
                                          style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.green[600]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          '✅ ${photo.uploadTime.toString().substring(11, 16)}',
                          style:
                              TextStyle(fontSize: 10, color: Colors.green[700]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Photo Upload Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  _initError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[600]),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _initError = null);
                    _initializeAuth();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Real Photo Upload'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 16),
              Text('Initializing authentication...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Real Photo Upload'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadExistingPhotos,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.green[50],
            child: Column(
              children: [
                Text(
                  '✅ Authenticated as erik.astrom@demo.com',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
                Text(
                  'PhotoService: ${EnvironmentConfig.settings.photoServiceUrl}',
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ],
            ),
          ),

          // Upload button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isUploading ? null : _pickAndUploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isUploading ? Colors.grey : Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isUploading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white)),
                        SizedBox(width: 12),
                        Text('Uploading...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo),
                        SizedBox(width: 8),
                        Text('Pick & Upload Photo'),
                      ],
                    ),
            ),
          ),

          // Photo grid
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: _buildPhotoGrid(),
            ),
          ),

          // Logs section
          Expanded(
            flex: 2,
            child: Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Logs',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Scrollbar(
                          controller: _scrollController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _logs
                                  .map((log) => Padding(
                                        padding: EdgeInsets.only(bottom: 2),
                                        child: Text(
                                          log,
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                            color: Colors.green.shade300,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class UploadedPhoto {
  final String id;
  final String filename;
  final DateTime uploadTime;
  final String? url;
  final String? thumbnailUrl;
  final Uint8List? imageBytes; // Store original image bytes

  UploadedPhoto({
    required this.id,
    required this.filename,
    required this.uploadTime,
    this.url,
    this.thumbnailUrl,
    this.imageBytes, // Allow storing image bytes
  });
}
