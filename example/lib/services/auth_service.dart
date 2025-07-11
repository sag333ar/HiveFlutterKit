import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';

class AuthService {
  final HiveFlutterKitPlatform hfk;
  final Function(String) showSnackBar; // To show snackbar messages
  final VoidCallback startTimer; // Callback to start timer for HiveAuth
  final VoidCallback cancelHiveAuth; // Callback to cancel HiveAuth

  AuthService({
    required this.hfk,
    required this.showSnackBar,
    required this.startTimer,
    required this.cancelHiveAuth,
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
      startTimer();
      final result = await hfk.loginWithHiveAuth(username, '');
      showSnackBar(
        'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
      );
      cancelHiveAuth();
    } catch (e) {
      cancelHiveAuth();
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
