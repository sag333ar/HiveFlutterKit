import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class AuthService {
  final HiveFlutterKitPlatform hfk;
  final Function(String) showSnackBar;
  final Function(String) initiateQrDisplay; // New callback
  final VoidCallback clearQrDisplay; // Renamed callback

  AuthService({
    required this.hfk,
    required this.showSnackBar,
    required this.initiateQrDisplay,
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
      // Step 1: Get the QR string for the login operation.
      // This assumes hfk.getQrString() is context-aware or that loginWithHiveAuth doesn't need prior session setup for QR.
      // If loginWithHiveAuth itself needs to be called to *start* a session before QR can be fetched,
      // this order might need adjustment based on hfk's specific API contract.
      // However, mirroring DhiveService's pattern:
      final String qrToDisplay = await hfk.getQrString();

      if (qrToDisplay.isEmpty) {
        showSnackBar('Error: Could not retrieve QR code for login.');
        return;
      }

      // Step 2: Ask the UI to display the QR code and start the timer.
      initiateQrDisplay(qrToDisplay);

      // Step 3: Await the actual login process completion.
      // This is the call that will typically block until the user scans the QR and authorizes.
      final result = await hfk.loginWithHiveAuth(username, '');

      showSnackBar(
        'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
      );
      clearQrDisplay(); // Clear QR from UI on successful login
    } catch (e) {
      clearQrDisplay(); // Clear QR from UI on error
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
