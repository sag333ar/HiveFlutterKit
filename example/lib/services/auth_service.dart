import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class AuthService {
  final HiveFlutterKitPlatform hfk;
  final Function(String) showSnackBar;
  final VoidCallback triggerQrDisplayAndTimer; // Updated callback
  final VoidCallback clearQrDisplay;

  AuthService({
    required this.hfk,
    required this.showSnackBar,
    required this.triggerQrDisplayAndTimer, // Updated
    required this.clearQrDisplay,
  });

  Future<void> loginWithHiveKeychain(String username) async {
    if (username.isEmpty) {
      showSnackBar('Username is required');
      return;
    }
    try {
      final result = await hfk.loginWithKeychain(username, '');
      showSnackBar(
        'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
      );
    } catch (e) {
      showSnackBar('Error: $e');
    }
  }

  Future<void> loginWithHiveAuth(String username) async {
    if (username.isEmpty) {
      showSnackBar('Username is required');
      return;
    }
    try {
      // Step 1: Trigger the UI to display the QR code and start its timer.
      // _initiateQrDisplayAndFetchFirstQr (in home.dart) will now handle fetching the initial QR string.
      triggerQrDisplayAndTimer();

      // Step 2: Await the actual login process completion.
      // This call will typically block until the user scans the QR and authorizes.
      // The UI (via _initiateQrDisplayAndFetchFirstQr) is responsible for showing the QR.
      final result = await hfk.loginWithHiveAuth(username, '');

      showSnackBar(
        'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
      );
      clearQrDisplay(); // Clear QR from UI on successful login
    } catch (e) {
      // If an error occurs (e.g. user rejects, timeout on native side), clear the QR.
      // The _initiateQrDisplayAndFetchFirstQr might also show an error if its initial QR fetch fails.
      clearQrDisplay();
      showSnackBar('Error during HiveAuth login: $e');
    }
  }

  Future<void> loginWithPlaintextKey(String username, String postingKey) async {
    if (username.isEmpty || postingKey.isEmpty) {
      showSnackBar('Username and Posting Key are required');
      return;
    }
    try {
      final result = await hfk.loginWithPlaintextKey(username, postingKey, '');
      showSnackBar(
        'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
      );
    } catch (e) {
      showSnackBar('Error: $e');
    }
  }
}
