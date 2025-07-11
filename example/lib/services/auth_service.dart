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
      // Potentially, loginWithHiveAuth itself might not immediately need a QR string,
      // but the platform will expect getQrString to be called by the UI layer.
      // The current hfk.loginWithHiveAuth might be a blocking call until auth completes or fails.
      // Or it might be non-blocking and expects UI to show QR.
      // Assuming it's non-blocking and QR is needed:
      final authSession = await hfk.loginWithHiveAuth(username, ''); // This initiates the process.
                                                                // The platform may now have a QR session.

      // Fetch the QR string to display
      final qrString = await hfk.getQrString();
      initiateQrDisplay(qrString); // Ask UI to show QR and start timer

      // The result of loginWithHiveAuth (authSession) would typically be awaited or handled via stream/callback
      // For this example, assuming `authSession` is the final result after QR scan.
      // In a real scenario, `hfk.loginWithHiveAuth` might return a stream or future that resolves after scan.
      // For now, we'll assume it's more direct for simplicity of refactoring the callbacks.
      // If `hfk.loginWithHiveAuth` is blocking and handles its own QR display internally (less likely for Flutter),
      // then `initiateQrDisplay` might be called before it.
      // Let's assume the sequence: initiate auth, get QR, display QR, await result.
      // The `final result = await hfk.loginWithHiveAuth(username, '');` line might represent the "await result" part.
      // The provided code implies `startTimer` (now `initiateQrDisplay`) is called before the main auth call.

      // Revised flow based on original `startTimer()` call position:
      final qrToDisplay = await hfk.getQrString(); // Get initial QR
      initiateQrDisplay(qrToDisplay); // Show QR and start UI timer

      final result = await hfk.loginWithHiveAuth(username, ''); // Perform login

      showSnackBar(
        'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
      );
      clearQrDisplay(); // Clear QR from UI
    } catch (e) {
      clearQrDisplay(); // Clear QR from UI on error
      showSnackBar('Error: $e');
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
