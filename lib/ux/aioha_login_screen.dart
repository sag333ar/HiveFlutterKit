import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ignore: must_be_immutable
class AiohaLoginScreen extends StatefulWidget {
  final HiveFlutterKitPlatform aioha;
  final List<Color> backgroundColors;
  final Color fontColor;
  final Color borderColor;
  final Color hiveKeychainButtonColor;
  final Color hiveKeychainTextColor;
  final Color hiveAuthButtonColor;
  final Color hiveAuthTextColor;
  final Color privatePostingKeyButtonColor;
  final Color privatePostingKeyTextColor;
  final Color withoutPrivatePostingKeyButtonColor;
  final Color withoutPrivatePostingKeyTextColor;
  final String title;
  final String subtitle;
  final Widget logoIcon;
  final String? logoImagePath;
  ThemeMode themeMode;
  final String proof;
  final void Function(BuildContext context, dynamic result)? uponLogin;

  AiohaLoginScreen({
    super.key,
    required this.aioha,
    this.backgroundColors = const [Color(0xFF2C3E50), Color(0xFF3498DB)],
    this.fontColor = Colors.white,
    this.borderColor = const Color(0xFFFFFFFF),
    this.hiveKeychainButtonColor = const Color(0xFF2ECC71),
    this.hiveKeychainTextColor = Colors.white,
    this.hiveAuthButtonColor = const Color(0xFFF39C12),
    this.hiveAuthTextColor = Colors.white,
    this.privatePostingKeyButtonColor = const Color(0xFF8E44AD),
    this.privatePostingKeyTextColor = Colors.white,
    this.withoutPrivatePostingKeyButtonColor = Colors.grey,
    this.withoutPrivatePostingKeyTextColor = Colors.white,
    this.title = 'Welcome to Hive',
    this.subtitle = 'Choose your login method',
    this.logoIcon = const Icon(
      Icons.hexagon_outlined,
      size: 64,
      color: Colors.white,
    ),
    this.logoImagePath,
    this.themeMode = ThemeMode.system,
    this.proof = '',
    this.uponLogin,
  });

  @override
  State<AiohaLoginScreen> createState() => _AiohaLoginScreenState();
}

class _AiohaLoginScreenState extends State<AiohaLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _postingKeyController =
      TextEditingController(); // Added for posting key
  var qrString = '';
  var timerDuration = 0;
  Timer? _authTimer;
  String _avatarUrl = '';
  bool _showPostingKeyLogin =
      false; // Track if posting key login mode is active

  Color get _dynamicFontColor =>
      widget.themeMode == ThemeMode.dark
          ? Colors.white
          : const Color(0xFF2C3E50);

  List<Color> get _dynamicBackgroundColors =>
      widget.themeMode == ThemeMode.dark
          ? widget.backgroundColors
          : [Colors.white, Color(0xFF3498DB)];

  Color get _dynamicBorderColor =>
      widget.themeMode == ThemeMode.dark
          ? widget.borderColor
          : const Color(0xFF2C3E50).withOpacity(0.2);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _updateAvatarUrl(String username) {
    if (username.isNotEmpty) {
      setState(() {
        _avatarUrl =
            'https://images.hive.blog/160x40/https://images.hive.blog/u/${username}/avatar';
      });
    } else {
      setState(() {
        _avatarUrl = '';
      });
    }
  }

  void _loginWithHiveKeychain() async {
    try {
      final result = await widget.aioha.loginWithKeychain(
        _usernameController.text,
        widget.proof,
      );
      _showMessage('Login Successful');
      if (widget.uponLogin != null) {
        widget.uponLogin!(context, result);
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  void _loginWithHiveAuth() async {
    try {
      _startTimer();
      final result = await widget.aioha.loginWithHiveAuth(
        _usernameController.text,
        widget.proof,
      );
      _showMessage('Login Successful');
      _cancelHiveAuth();
      if (widget.uponLogin != null) {
        widget.uponLogin!(context, result);
      }
    } catch (e) {
      _cancelHiveAuth();
      _showMessage('Error: $e');
    }
  }

  void _loginWithPlaintextKey() async {
    try {
      final username = _usernameController.text;
      final postingKey = _postingKeyController.text;

      if (username.isEmpty || postingKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username and Posting Key are required'),
          ),
        );
        return;
      }

      final result = await widget.aioha.loginWithPlaintextKey(
        username,
        postingKey,
        widget.proof,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
          ),
        ),
      );
      if (widget.uponLogin != null) {
        widget.uponLogin!(context, result);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _startTimer() async {
    qrString = await widget.aioha.getQrString();
    setState(() {
      timerDuration = 30;
    });

    _authTimer?.cancel();
    _authTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timerDuration > 0) {
        qrString = await widget.aioha.getQrString();
        setState(() {
          timerDuration--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _cancelHiveAuth() {
    _authTimer?.cancel();
    setState(() {
      qrString = '';
      timerDuration = 0;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E2A38),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleThemeMode() {
    setState(() {
      if (widget.themeMode == ThemeMode.dark) {
        widget.themeMode = ThemeMode.light;
      } else {
        widget.themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _dynamicBackgroundColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    widget.themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: _dynamicFontColor,
                  ),
                  onPressed: _toggleThemeMode,
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: _dynamicFontColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _dynamicBorderColor,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (widget.logoImagePath != null)
                                Image.asset(
                                  widget.logoImagePath!,
                                  height: 64,
                                  width: 64,
                                )
                              else
                                widget.logoIcon,
                              const SizedBox(height: 24),
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: _dynamicFontColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _dynamicFontColor.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 32),
                              TextField(
                                controller: _usernameController,
                                style: TextStyle(color: _dynamicFontColor),
                                onChanged: _updateAvatarUrl,
                                cursorColor: _dynamicFontColor,
                                decoration: InputDecoration(
                                  hintText: 'Enter username',
                                  hintStyle: TextStyle(
                                    color: _dynamicFontColor.withOpacity(0.5),
                                  ),
                                  prefixIcon:
                                      _avatarUrl.isEmpty
                                          ? Icon(
                                            Icons.person_outline,
                                            color: _dynamicFontColor,
                                          )
                                          : Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                    _avatarUrl,
                                                  ),
                                            ),
                                          ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: _dynamicFontColor.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: _dynamicFontColor,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: _dynamicFontColor.withOpacity(0.1),
                                ),
                              ),
                              // Show posting key textfield if in posting key login mode
                              if (_showPostingKeyLogin) ...[
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _postingKeyController,
                                  obscureText: true,
                                  style: TextStyle(color: _dynamicFontColor),
                                  cursorColor: _dynamicFontColor,
                                  decoration: InputDecoration(
                                    hintText: 'Enter private posting key',
                                    hintStyle: TextStyle(
                                      color: _dynamicFontColor.withOpacity(0.5),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.vpn_key,
                                      color: _dynamicFontColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: _dynamicFontColor.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: _dynamicFontColor,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: _dynamicFontColor.withOpacity(
                                      0.1,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              // Show login buttons or posting key login buttons based on mode
                              if (!_showPostingKeyLogin) ...[
                                ElevatedButton(
                                  onPressed: _loginWithHiveKeychain,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        widget.hiveKeychainButtonColor,
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // const Icon(Icons.key),
                                      Image.asset(
                                        'packages/hive_flutter_kit/assets/images/hive-keychain-logo.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Hive Keychain',
                                        style: TextStyle(
                                          color: widget.hiveKeychainTextColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loginWithHiveAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.hiveAuthButtonColor,
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // const Icon(Icons.qr_code),
                                      Image.asset(
                                        'packages/hive_flutter_kit/assets/images/hiveauth_icon.png',
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Hive Auth',
                                        style: TextStyle(
                                          color: widget.hiveAuthTextColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showPostingKeyLogin = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        widget.privatePostingKeyButtonColor,
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.vpn_key, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Private Posting Key',
                                        style: TextStyle(
                                          color:
                                              widget.privatePostingKeyTextColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                ElevatedButton(
                                  onPressed: _loginWithPlaintextKey,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        widget.privatePostingKeyButtonColor,
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Login with Private Posting Key',
                                        style: TextStyle(
                                          color:
                                              widget.privatePostingKeyTextColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showPostingKeyLogin = false;
                                      _postingKeyController.clear();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        widget
                                            .withoutPrivatePostingKeyButtonColor,
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Login without Private Posting Key',
                                        style: TextStyle(
                                          color:
                                              widget
                                                  .withoutPrivatePostingKeyTextColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (_usernameController.text.isNotEmpty &&
                            qrString.isNotEmpty &&
                            timerDuration > 0) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    final uri = Uri.tryParse(qrString);
                                    if (uri != null) {
                                      launchUrl(uri);
                                    }
                                  },
                                  child: QrImageView(
                                    data: qrString,
                                    version: QrVersions.auto,
                                    size: 200.0,
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: timerDuration / 30,
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFF39C12),
                                        ),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: _cancelHiveAuth,
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'Cancel Authentication',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
