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
      // Step 1: Initiate the login process with HiveAuth.
      // This call is expected to set up the necessary session on the native side.
      // We will await its Future *after* displaying the QR code.
      Future<LoginResult> loginOperationFuture = hfk.loginWithHiveAuth(username, '');

      // Step 2: Fetch the QR string for the initiated session.
      final String qrToDisplay = await hfk.getQrString();

      if (qrToDisplay.isEmpty) {
        // If QR is still empty here, the platform plugin might not have generated/provided it
        // even after loginWithHiveAuth was called.
        showSnackBar('Error: Could not retrieve QR code for login.');
        // We might not want to call clearQrDisplay if initiateQrDisplay was never called.
        return;
      }

      // Step 3: Ask the UI to display the QR code and start its timer.
      initiateQrDisplay(qrToDisplay);

      // Step 4: Await the completion of the login operation initiated in Step 1.
      // This Future should resolve after the user scans the QR and the backend confirms.
      final LoginResult result = await loginOperationFuture;

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
