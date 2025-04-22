import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:aioha_flutter_core/aioha_flutter_core.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _aiohaFlutterCorePlugin = AiohaFlutterCore();

  final TextEditingController _usernameController = TextEditingController();
  var qrString = '';
  var timerDuration = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void _loginWithHiveKeychain() async {
    try {
      final result = await _aiohaFlutterCorePlugin.loginWithKeychain(
        _usernameController.text,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Success: $result')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _loginWithHiveAuth() async {
    try {
      _startTimer();
      final result = await _aiohaFlutterCorePlugin.loginWithHiveAuth(
        _usernameController.text,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Success: $result')));
      _cancelHiveAuth();
    } catch (e) {
      _cancelHiveAuth();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _logout() async {
    try {
      final result = await _aiohaFlutterCorePlugin.logout();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully logged out: $result')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _singleVote() async {
    try {
      _startTimer();
      final result = await _aiohaFlutterCorePlugin.singleVote(
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

  void _comment() async {
    try {
      final result = await _aiohaFlutterCorePlugin.comment(
        'parentAuthor',
        'parentPermlink',
        'permlink',
        'title',
        'body',
        {'foo': 'bar'},
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Comment Success: $result')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Comment Error: $e')));
    }
  }

  void _commentWithOptions() async {
    try {
      final result = await _aiohaFlutterCorePlugin.commentWithOptions(
        'parentAuthor',
        'parentPermlink',
        'permlink',
        'title',
        'body',
        {'foo': 'bar'},
        {
          'author': await _aiohaFlutterCorePlugin.getCurrentUser(),
          'permlink': 'permlink',
          'max_accepted_payout': '1000000.000 HBD',
          'percent_hbd': 10000,
          'allow_votes': true,
          'allow_curation_rewards': true,
          'extensions': [
            [
              0,
              {
                'beneficiaries': [
                  {'account': 'alice', 'weight': 100},
                  {'account': 'bob', 'weight': 150},
                ],
              },
            ],
          ],
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CommentWithOptions Success: $result')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CommentWithOptions Error: $e')));
    }
  }

  void _deleteComment() async {
    try {
      _startTimer();
      final result = await _aiohaFlutterCorePlugin.deleteComment(
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

  void _reblog() async {
    try {
      final result = await _aiohaFlutterCorePlugin.reblog(
        'sagarkothari',
        'rblmtojs',
        true,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reblog Success: $result')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reblog Error: $e')));
    }
  }

  void _removeReblog() async {
    try {
      final result = await _aiohaFlutterCorePlugin.reblog(
        'sagarkothari',
        'rblmtojs',
        false,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Remove Reblog Success: $result')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Remove Reblog Error: $e')));
    }
  }

  void _follow() async {
    try {
      final result = await _aiohaFlutterCorePlugin.follow(
        'sagarkothari',
        false,
      );
      print('Follow result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Follow Success: $result')));
    } catch (e) {
      print('Follow failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Follow Error: $e')));
    }
  }

  void _unfollow() async {
    try {
      final result = await _aiohaFlutterCorePlugin.follow('sagarkothari', true);
      print('Unfollow result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unfollow Success: $result')));
    } catch (e) {
      print('Unfollow failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unfollow Error: $e')));
    }
  }

  void _startTimer() async {
    var string = await _aiohaFlutterCorePlugin.getQrString();
    setState(() {
      qrString = string;
      timerDuration = 30;
    });
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timerDuration > 0) {
        var string = await _aiohaFlutterCorePlugin.getQrString();
        setState(() {
          qrString = string;
          timerDuration--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _cancelHiveAuth() {
    setState(() {
      qrString = '';
      timerDuration = 0;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _aiohaFlutterCorePlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Flutter Aioha Core Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // if (!Platform.isAndroid && !Platform.isIOS) ...[
            ElevatedButton(
              onPressed: _loginWithHiveKeychain,
              child: const Text('Login with Hive Keychain'),
            ),
            // ],
            ElevatedButton(
              onPressed: _loginWithHiveAuth,
              child: const Text('Login with HiveAuth'),
            ),
            ElevatedButton(
              onPressed: () async {
                String username =
                    await _aiohaFlutterCorePlugin.getCurrentUser();
                username = username.replaceAll('"', '');
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('User Profile'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              'https://images.hive.blog/u/$username/avatar?id=test',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '@$username',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Show User Profile'),
            ),
            ElevatedButton(onPressed: _logout, child: const Text('Logout')),
            ElevatedButton(onPressed: _singleVote, child: const Text('Vote')),
            ElevatedButton(
              onPressed: _deleteComment,
              child: const Text('Delete Comment'),
            ),
            ElevatedButton(onPressed: _reblog, child: const Text('Reblog')),
            ElevatedButton(
              onPressed: _removeReblog,
              child: const Text('Remove Reblog'),
            ),
            ElevatedButton(onPressed: _follow, child: const Text('Follow')),
            ElevatedButton(onPressed: _unfollow, child: const Text('Unfollow')),
            // ElevatedButton(onPressed: _comment, child: const Text('Comment')),
            // ElevatedButton(
            //   onPressed: _commentWithOptions,
            //   child: const Text('Comment With Options'),
            // ),
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
