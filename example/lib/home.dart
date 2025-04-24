import 'dart:async';

import 'package:aioha_flutter_core/aioha_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AiohaCore aiohaCore;
  final TextEditingController _usernameController = TextEditingController();
  var qrString = '';
  var timerDuration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    aiohaCore = Provider.of<AiohaCore>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
  }

  void _loginWithHiveKeychain() async {
    try {
      final result = await aiohaCore.plugin.loginWithKeychain(
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
      final result = await aiohaCore.plugin.loginWithHiveAuth(
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
      final result = await aiohaCore.plugin.logout();
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
      final result = await aiohaCore.plugin.singleVote(
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
      final result = await aiohaCore.plugin.comment(
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
      final result = await aiohaCore.plugin.commentWithOptions(
        'parentAuthor',
        'parentPermlink',
        'permlink',
        'title',
        'body',
        {'foo': 'bar'},
        {
          'author': await aiohaCore.plugin.getCurrentUser(),
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
      final result = await aiohaCore.plugin.deleteComment(
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
      final result = await aiohaCore.plugin.reblog(
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
      final result = await aiohaCore.plugin.reblog(
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
      final result = await aiohaCore.plugin.follow('sagarkothari', false);
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

  void _switchUser() async {
    if (aiohaCore.plugin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Aioha is not initialized')),
      );
      return;
    }

    try {
      final otherLogins = await aiohaCore.plugin.getOtherLogins();
      print('Other logged-in users: $otherLogins');

      if (otherLogins.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other logged-in users available')),
        );
        return;
      }

      // Show a dialog to select a user
      final selectedUser = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select User to Switch'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: otherLogins.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(otherLogins[index]),
                    onTap: () {
                      Navigator.of(context).pop(otherLogins[index]);
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedUser == null) {
        // User canceled the dialog
        return;
      }

      final result = await aiohaCore.plugin.switchUser(selectedUser);
      print('Switch user result: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched to user: $selectedUser')),
      );
    } catch (e) {
      print('Switch user failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _unfollow() async {
    try {
      final result = await aiohaCore.plugin.follow('sagarkothari', true);
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

  void _claimRewards() async {
    try {
      final result = await aiohaCore.plugin.claimRewards();
      print('Claim Rewards result: $result');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Claim Rewards Success: $result')));
    } catch (e) {
      print('Claim Rewards failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Claim Rewards Error: $e')));
    }
  }

  void _signMessage() async {
    try {
      _startTimer();
      final result = await aiohaCore.plugin.signMessage(
        'Hello, Aioha!',
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

  void _startTimer() async {
    var string = await aiohaCore.plugin.getQrString();
    setState(() {
      qrString = string;
      timerDuration = 30;
    });
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timerDuration > 0) {
        var string = await aiohaCore.plugin.getQrString();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Flutter Aioha Core Example'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                onPressed: _switchUser,
                child: const Text('Switch User'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String username = await aiohaCore.plugin.getCurrentUser();
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
              ElevatedButton(
                onPressed: _unfollow,
                child: const Text('Unfollow'),
              ),
              ElevatedButton(
                onPressed: _claimRewards,
                child: const Text('Claim Rewards'),
              ),
              ElevatedButton(
                onPressed: _signMessage,
                child: const Text('Sign Message'),
              ),
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
      ),
    );
  }
}
