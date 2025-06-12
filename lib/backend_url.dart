import 'dart:io';
import 'package:flutter/foundation.dart';

String getBackendBaseUrl({int port = 8080}) {
  if (kIsWeb) {
    return 'http://localhost:$port';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:$port';
  }
  return 'http://localhost:$port';
}
