import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class AuthService {
  final HiveFlutterKitPlatform hfk;
  final Function(String) showSnackBar;
  final VoidCallback startHiveAuthTimer; // Reverted to original conceptual name
  final VoidCallback cancelHiveAuthTimer; // Reverted to original conceptual name

  AuthService({
    required this.hfk,
    required this.showSnackBar,
    required this.startHiveAuthTimer,
    required this.cancelHiveAuthTimer,
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
      // Trigger the UI to start the QR display process (which includes initial QR fetch)
      startHiveAuthTimer();

      // Await the login operation. _startTimer in UI is already running.
      final result = await hfk.loginWithHiveAuth(username, '');

      showSnackBar(
        'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
      );
    } catch (e) {
      showSnackBar('Error during HiveAuth login: $e');
    } finally {
      // Always cancel the QR display and timer, whether success or error.
      cancelHiveAuthTimer();
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
