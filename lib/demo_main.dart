import 'package:flutter/material.dart';
import 'screens/photo_upload_demo.dart';

void main() {
  runApp(PhotoUploadDemoApp());
}

class PhotoUploadDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Upload Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PhotoUploadDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}
