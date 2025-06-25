import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ignore: must_be_immutable
class LoginScreen extends StatefulWidget {
  final HiveFlutterKitPlatform hfk;
  final List<Color>? backgroundColors;
  final Color? fontColor;
  final Color? borderColor;
  final Color? hiveKeychainButtonColor;
  final Color? hiveKeychainTextColor;
  final Color? hiveAuthButtonColor;
  final Color? hiveAuthTextColor;
  final Color? privatePostingKeyButtonColor;
  final Color? privatePostingKeyTextColor;
  final Color? withoutPrivatePostingKeyButtonColor;
  final Color? withoutPrivatePostingKeyTextColor;
  final String title;
  final String subtitle;
  final Widget logoIcon;
  final String? logoImagePath;
  final String proof;
  final void Function(BuildContext context, dynamic result)? uponLogin;

  LoginScreen({
    super.key,
    required this.hfk,
    this.backgroundColors,
    this.fontColor,
    this.borderColor,
    this.hiveKeychainButtonColor,
    this.hiveKeychainTextColor = Colors.white,
    this.hiveAuthButtonColor,
    this.hiveAuthTextColor = Colors.white,
    this.privatePostingKeyButtonColor,
    this.privatePostingKeyTextColor = Colors.white,
    this.withoutPrivatePostingKeyButtonColor,
    this.withoutPrivatePostingKeyTextColor = Colors.white,
    this.title = 'Welcome to Hive',
    this.subtitle = 'Choose your login method',
    this.logoIcon = const Icon(
      Icons.hexagon_outlined,
      size: 64,
      color: Colors.grey,
    ),
    this.logoImagePath,
    this.proof = '',
    this.uponLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _postingKeyController =
      TextEditingController(); // Added for posting key
  var qrString = '';
  var timerDuration = 0;
  Timer? _authTimer;
  String _avatarUrl = '';
  bool _showPostingKeyLogin = false;
  bool _isKeychainAvailable = false;
  bool _checkedKeychain = false;

  // Auto-detect theme mode
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  // Dynamic colors
  List<Color> get _dynamicBackgroundColors {
    return widget.backgroundColors ??
        (_isDarkMode
            ? [Color(0xFF121212), Color(0xFF1E1E1E)]
            : [Colors.white, Colors.white]);
  }

  Color get _dynamicFontColor {
    return widget.fontColor ?? (_isDarkMode ? Colors.white : Colors.black);
  }

  Color get _dynamicBorderColor {
    return widget.borderColor ??
        (_isDarkMode
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.2));
  }

  // Button colors with dark mode variants
  Color get _hiveKeychainButtonColor {
    return widget.hiveKeychainButtonColor ??
        (_isDarkMode ? Colors.green.shade800 : Colors.green);
  }

  Color get _hiveAuthButtonColor {
    return widget.hiveAuthButtonColor ??
        (_isDarkMode ? Colors.orange.shade400 : Colors.orange);
  }

  Color get _privatePostingKeyButtonColor {
    return widget.privatePostingKeyButtonColor ??
        (_isDarkMode ? Colors.deepPurple.shade400 : Colors.deepPurple);
  }

  Color get _withoutPrivatePostingKeyButtonColor {
    return widget.withoutPrivatePostingKeyButtonColor ??
        (_isDarkMode ? Colors.grey.shade800 : Colors.grey);
  }

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
      final result = await widget.hfk.loginWithKeychain(
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
      final result = await widget.hfk.loginWithHiveAuth(
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

      final result = await widget.hfk.loginWithPlaintextKey(
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
    qrString = await widget.hfk.getQrString();
    setState(() {
      timerDuration = 30;
    });

    _authTimer?.cancel();
    _authTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timerDuration > 0) {
        qrString = await widget.hfk.getQrString();
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

  @override
  void initState() {
    super.initState();
    _checkKeychainAvailability();
  }

  Future<void> _checkKeychainAvailability() async {
    // Only check on web, always hide on mobile
    if (kIsWeb) {
      try {
        final available = await widget.hfk.isHiveKeychainAvailable();
        setState(() {
          _isKeychainAvailable = available == true;
          _checkedKeychain = true;
        });
      } catch (_) {
        setState(() {
          _isKeychainAvailable = false;
          _checkedKeychain = true;
        });
      }
    } else {
      // On mobile, always hide
      setState(() {
        _isKeychainAvailable = false;
        _checkedKeychain = true;
      });
    }
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
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _dynamicBorderColor,
                              width: 1,
                            ),
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
                                cursorColor: _dynamicFontColor,
                                onChanged: (value) {
                                  String sanitized =
                                      value
                                          .toLowerCase()
                                          .replaceAll(
                                            RegExp(r'[^a-z0-9._-]'),
                                            '',
                                          )
                                          .trim();

                                  if (value != sanitized) {
                                    final cursorPos =
                                        _usernameController.selection;
                                    _usernameController
                                        .value = TextEditingValue(
                                      text: sanitized,
                                      selection: cursorPos.copyWith(
                                        baseOffset: min(
                                          cursorPos.start,
                                          sanitized.length,
                                        ),
                                        extentOffset: min(
                                          cursorPos.end,
                                          sanitized.length,
                                        ),
                                      ),
                                    );
                                  }

                                  _updateAvatarUrl(sanitized);
                                },
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
                                // Only show Hive Keychain button if available and not on mobile
                                if (_isKeychainAvailable && _checkedKeychain)
                                  ElevatedButton(
                                    onPressed: _loginWithHiveKeychain,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _hiveKeychainButtonColor,
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
                                if (_isKeychainAvailable && _checkedKeychain)
                                  const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loginWithHiveAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _hiveAuthButtonColor,
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
                                        _privatePostingKeyButtonColor,
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
                                        Icons.vpn_key,
                                        color:
                                            widget.privatePostingKeyTextColor,
                                      ),
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
                                    backgroundColor: _hiveKeychainButtonColor,
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
                                      Flexible(
                                        child: Text(
                                          overflow: TextOverflow.ellipsis,
                                          'Login with Private Posting Key',
                                          style: TextStyle(
                                            color:
                                              widget.privatePostingKeyTextColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                                        _privatePostingKeyButtonColor,
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
                                        color:
                                            widget
                                                .withoutPrivatePostingKeyTextColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          overflow: TextOverflow.ellipsis,
                                          'Login without Private Posting Key',
                                          style: TextStyle(
                                            color:
                                                widget
                                                    .withoutPrivatePostingKeyTextColor,
                                            fontSize: 18,
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
                        if (_usernameController.text.isNotEmpty &&
                            qrString.isNotEmpty &&
                            timerDuration > 0) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _dynamicBorderColor,
                                width: 1,
                              ),
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
