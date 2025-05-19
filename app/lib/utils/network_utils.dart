import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  static Future<bool> hasInternetConnection() async {
    if (kIsWeb) {
      // For web, assume connection (browser handles this)
      return true;
    }
    
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
