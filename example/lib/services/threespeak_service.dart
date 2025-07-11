import 'package:hive_flutter_kit/hive_flutter_kit.dart'; // Provides HiveFlutterKitPlatform
import 'package:flutter/foundation.dart'; // For debugPrint

class ThreeSpeakService {
  final HiveFlutterKitPlatform hfk;
  final Function(String message) showSnackBar; // Callback to show SnackBars

  ThreeSpeakService({required this.hfk, required this.showSnackBar});

  Future<void> checkThreespeakInAccountAuths(String username) async {
    if (username.isEmpty) {
      showSnackBar('Username is required');
      return;
    }
    try {
      bool hasThreespeak = await hfk.hasThreespeakInAccountAuths(username);
      debugPrint('threespeak present in accountAuths: $hasThreespeak');
      showSnackBar('Threespeak authorization present: $hasThreespeak');
    } catch (e) {
      debugPrint('Error checking threespeak in accountAuths: $e');
      showSnackBar('Error checking Threespeak auth: $e');
    }
  }

  // Other ThreeSpeak specific methods can be added here.
  // For example, if there were direct calls for video uploads, fetching 3speak videos, etc.
  // that are not already part of a widget.
}
