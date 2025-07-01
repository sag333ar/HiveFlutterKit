import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/ux/login_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountAuth extends StatefulWidget {
  const AccountAuth({super.key});

  @override
  State<AccountAuth> createState() => _AccountAuthState();
}

class _AccountAuthState extends State<AccountAuth> {
  late HiveFlutterKitPlatform hfk;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _postingKeyController = TextEditingController();

  var qrString = '';
  var timerDuration = 0;

  @override
  void initState() {
    super.initState();
    hfk = HiveFlutterKitPlatform.instance;
  }

  void _loginWithHiveKeychain() async {
    try {
      final result = await hfk.loginWithKeychain(_usernameController.text, '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _loginWithHiveAuth() async {
    try {
      _startTimer();
      final result = await hfk.loginWithHiveAuth(_usernameController.text, '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
          ),
        ),
      );
      _cancelHiveAuth();
    } catch (e) {
      _cancelHiveAuth();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _cancelHiveAuth() {
    setState(() {
      qrString = '';
      timerDuration = 0;
    });
  }

  void _startTimer() async {
    var result = await hfk.getQrString();
    setState(() {
      qrString = result;
      timerDuration = 30;
    });
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timerDuration > 0) {
        var result = await hfk.getQrString();
        setState(() {
          qrString = result;
          timerDuration--;
        });
      } else {
        timer.cancel();
      }
    });
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

      final result = await hfk.loginWithPlaintextKey(username, postingKey, '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Success: ${result.success} Proof: ${result.proof}, Username: ${result.username}, Challenge: ${result.challenge}, PublicKey: ${result.publicKey}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _getVotingPower() async {
    try {
      final username = _usernameController.text;

      if (username.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Username is required')));
        return;
      }

      var result = await hfk.getVotingPower(username);
      debugPrint(
        "Voting Power: ${result.downvotePower}, ${result.upvotePower}",
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _addAccountAuthority() async {
    try {
      final username = _usernameController.text;
      if (username.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Username is required')));
        return;
      }
      // Example: add 'hfk' to Posting authority with weight 1
      final result = await hfk.addAccountAuthority("threespeak", 'posting', 1);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Add Account Authority: $result')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add Account Authority Error: $e')),
      );
    }
  }

  void _removeAccountAuthority() async {
    try {
      final username = _usernameController.text;
      if (username.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Username is required')));
        return;
      }
      // Example: remove 'hfk' from Posting authority
      final result = await hfk.removeAccountAuthority('threespeak', 'posting');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove Account Authority: $result')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove Account Authority Error: $e')),
      );
    }
  }

  Future<void> _checkThreespeakInAccountAuths() async {
    try {
      final username = _usernameController.text;
      if (username.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Username is required')));
        return;
      }
      bool hasThreespeak = await hfk.hasThreespeakInAccountAuths(username);
      debugPrint('threespeak present in accountAuths: $hasThreespeak');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('threespeak present: $hasThreespeak')),
      );
    } catch (e) {
      debugPrint('Error checking threespeak in accountAuths: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _signMessage() async {
    try {
      _startTimer();
      final result = await hfk.signMessage(
        'Hello, hfk!',
        'Posting', // Add KeyType here
      );
      print('Sign Message result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign Message Success: $result')));
      _cancelHiveAuth();
    } catch (e) {
      print('Sign Message failed: $e');
      _cancelHiveAuth();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign Message Error: $e')));
    }
  }

  void _deleteComment() async {
    try {
      _startTimer();
      final result = await hfk.deleteComment(
        'permlinktodel',
      ); //Permlink to delete
      // Replace with the actual permlink you want to delete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete Comment Success: $result')),
      );
      _cancelHiveAuth();
    } catch (e) {
      _cancelHiveAuth();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete Comment Error: $e')));
    }
  }

  void _singleVote() async {
    try {
      _startTimer();
      final result = await hfk.singleVote(
        'sagarkothari88',
        'aihoa-based-login-with-hiveauth-and-sign-a-message-works-well-with-ios-app-now',
        1000,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vote Success: $result')));
      _cancelHiveAuth();
    } catch (e) {
      _cancelHiveAuth();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vote Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ThreeSpeak Account Authority')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _postingKeyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Posting Key (for plaintext login)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _addAccountAuthority,
              child: const Text('Add Account Authority'),
            ),
            ElevatedButton(
              onPressed: _removeAccountAuthority,
              child: const Text('Remove Account Authority'),
            ),
            ElevatedButton(
              onPressed: _checkThreespeakInAccountAuths,
              child: const Text('Check threespeak in accountAuths'),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loginWithHiveKeychain,
              child: const Text('Login with Hive Keychain'),
            ),
            ElevatedButton(
              onPressed: _loginWithHiveAuth,
              child: const Text('Login with HiveAuth'),
            ),

            ElevatedButton(
              onPressed: _loginWithPlaintextKey,
              child: const Text('Login with Plaintext Key'),
            ),

            ElevatedButton(
              child: Text('Get Voting power'),
              onPressed: _getVotingPower,
            ),
            ElevatedButton(onPressed: _singleVote, child: const Text('Vote')),
            ElevatedButton(
              onPressed: _deleteComment,
              child: const Text('Delete Comment'),
            ),
            ElevatedButton(
              onPressed: _signMessage,
              child: const Text('Sign Message'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => Dialog(
                                insetPadding: EdgeInsets.zero,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: LoginScreen(hfk: hfk),
                                ),
                              ),
                        );
                      },
                      child: const Text('hfk Login Screen User (Dialog)'),
                    ),
                  ),
                ],
              ),
            ),
            qrString.isEmpty || timerDuration == 0
                ? const SizedBox.shrink()
                : Column(
                  children: [
                    InkWell(
                      child: QrImageView(
                        data: qrString,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                      onTap: () {
                        var uri = Uri.tryParse(qrString);
                        if (uri != null) {
                          launchUrl(uri);
                        }
                      },
                    ),
                    LinearProgressIndicator(
                      value: timerDuration / 30,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _cancelHiveAuth,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
