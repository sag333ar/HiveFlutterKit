import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/services/api_service.dart';
import 'package:hive_flutter_kit/ux/login_screen.dart';

class ThreeSpeakLoginScreen extends StatelessWidget {
  final HiveFlutterKitPlatform hfk;
  final List<Color>? backgroundColors;
  final Color? fontColor;
  final Color? borderColor;
  final Color? hiveKeychainButtonColor;
  final Color? hiveKeychainTextColor;
  final Color? hiveAuthButtonColor;
  final Color? hiveAuthTextColor;
  final String? title;
  final String? subtitle;
  final Widget? logoIcon;
  final Function(BuildContext context, String token, String username, String? postingKey)? uponLogin;

  const ThreeSpeakLoginScreen({
    Key? key,
    required this.hfk,
    this.backgroundColors,
    this.fontColor,
    this.borderColor,
    this.hiveKeychainButtonColor,
    this.hiveKeychainTextColor,
    this.hiveAuthButtonColor,
    this.hiveAuthTextColor,
    this.title,
    this.subtitle,
    this.logoIcon,
    this.uponLogin,
  }) : super(key: key);

  Future<void> _handleLogin(BuildContext context, LoginModel result, String? postingKey) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final apiService = ApiService();
      final response = await apiService.handleLogin(result);
      final token = response['token'];
      final username = result.username;
      Navigator.of(context).pop(); // Remove loading dialog
      if (token != null) {
        uponLogin!(context, token, username!, postingKey!);
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login API did not return token.")),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Remove loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login API error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provide default values if null
    final String safeTitle = title ?? 'Welcome to 3Speak';
    final String safeSubtitle = subtitle ?? 'Login to continue';
    final Widget safeLogoIcon = logoIcon ??
        const Icon(
          Icons.video_library,
          size: 64,
          color: Colors.deepPurple,
        );

    return Stack(
      children: [
        LoginScreen(
          hfk: hfk,
          backgroundColors: backgroundColors,
          fontColor: fontColor,
          borderColor: borderColor,
          hiveKeychainButtonColor: hiveKeychainButtonColor,
          hiveKeychainTextColor: hiveKeychainTextColor,
          hiveAuthButtonColor: hiveAuthButtonColor,
          hiveAuthTextColor: hiveAuthTextColor,
          title: safeTitle,
          subtitle: safeSubtitle,
          logoIcon: safeLogoIcon,
          uponLogin: (context, loginResult, [postingKey]) async {
            if (loginResult is LoginModel) {
              await _handleLogin(context, loginResult, postingKey!);
            }
          },
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey
                : Colors.black,
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Back',
          ),
        ),
      ],
    );
  }
}