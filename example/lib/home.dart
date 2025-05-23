import 'dart:async';
import 'dart:convert';

import 'package:aioha_flutter_core/aioha_flutter_core_platform_interface.dart';
import 'package:aioha_flutter_core/dhive_flutter_platform_interface.dart';
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
  late AiohaFlutterCorePlatform aioha;
  late DhiveFlutterPlatform dhive;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _postingKeyController = TextEditingController();

  var qrString = '';
  var timerDuration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    aioha = Provider.of<AiohaFlutterCorePlatform>(context, listen: false);
    dhive = Provider.of<DhiveFlutterPlatform>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
  }

  void _loginWithHiveKeychain() async {
    try {
      final result = await aioha.loginWithKeychain(
        _usernameController.text,
        '',
      );
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
      final result = await aioha.loginWithHiveAuth(
        _usernameController.text,
        '',
      );
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

      final result = await aioha.loginWithPlaintextKey(
        username,
        postingKey,
        '',
      );
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

      var result = await dhive.getVotingPower(username);
      debugPrint(
        "Voting Power: ${result.downvotePower}, ${result.upvotePower}",
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _logout() async {
    try {
      final userStatus = await aioha.getCurrentUser();

      if (userStatus == null ||
          userStatus == '' ||
          userStatus.contains('No user is currently logged in')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is currently logged in')),
        );
        return;
      }
      await aioha.logout();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Successfully logged out')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error during logout: $e')));
    }
  }

  void _singleVote() async {
    try {
      _startTimer();
      final result = await aioha.singleVote(
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
      final result = await aioha.comment(
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
      final jsonMetadata = {
        "tags": ["sagar", "kothari"],
        "app": "checkinwithxyz/1.0.0",
        "username": "sagar",
        "image": [
          "https://canopas-blogs.s3.ap-south-1.amazonaws.com/my_profile_c0f157624c.jpeg",
        ],
        "onboarder": "sagarkothari",
        "introductionText": "Hello, I am a new user",
        "communityName": "blabla",
        "lightningAddress": "bla@bla.v4v.app",
      };

      final Map<String, dynamic> options = {
        "author": "shaktimaaan",
        "permlink": "asdfasfaasdfsdfasdfasfasdf",
        "allow_votes": true,
        "max_accepted_payout": "100000.000 SBD",
        "percent_hbd": 10000,
        "allow_curation_rewards": true,
        "extensions": [
          [
            0,
            {
              "beneficiaries": [
                {"weight": 3000, "account": "threespeakselfie"},
              ],
            },
          ],
        ],
      };

      final result = await aioha.commentWithOptions(
        '',
        'hive-184437',
        'asdfasfaasdfsdfasdfasfasdf',
        'this is a test title from aioha comment with options',
        'I am going to try this comment with options and see how it works and if it works or not and if it works or not asdfafadsfadsfadsfadsfadsfadsfadsfadsfadsfadsfadsfadsfadsfadsfadsfads',
        jsonEncode(jsonMetadata),
        jsonEncode(options),
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
      final result = await aioha.deleteComment(
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
      final result = await aioha.reblog('sagarkothari', 'rblmtojs', true);
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
      final result = await aioha.reblog('sagarkothari', 'rblmtojs', false);
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
      final result = await aioha.follow('sagarkothari', false);
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
    if (aioha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Aioha is not initialized')),
      );
      return;
    }

    try {
      final otherLogins = await aioha.getOtherLogins();
      print('Other logged-in users: $otherLogins');

      if (otherLogins.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other logged-in users available')),
        );
        return;
      }

      // Show a dialog to select or remove a user
      await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Manage Logged-in Users'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: otherLogins.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(otherLogins[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        try {
                          final result = await aioha.removeOtherLogin(
                            otherLogins[index],
                          );
                          print('Removed user: $result');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Removed user: ${otherLogins[index]}',
                              ),
                            ),
                          );
                          Navigator.of(context).pop(); // Close the dialog
                        } catch (e) {
                          print('Failed to remove user: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to remove user: ${otherLogins[index]}',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    onTap: () async {
                      final selectedUser = otherLogins[index];
                      final result = await aioha.switchUser(selectedUser);
                      print('Switch user result: $result');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Switched to user: $selectedUser'),
                        ),
                      );
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  );
                },
              ),
            ),
          );
        },
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
      final result = await aioha.follow('sagarkothari', true);
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
      final result = await aioha.claimRewards();
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
      final result = await aioha.signMessage(
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

  void _addAccountAuthority() async {
    try {
      final username = _usernameController.text;
      if (username.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Username is required')));
        return;
      }
      // Example: add 'aioha' to Posting authority with weight 1
      final result = await aioha.addAccountAuthority(
        "threespeak",
        'posting',
        1,
      );
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
      // Example: remove 'aioha' from Posting authority
      final result = await aioha.removeAccountAuthority(
        'threespeak',
        'posting',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove Account Authority: $result')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove Account Authority Error: $e')),
      );
    }
  }

  void _startTimer() async {
    var result = await aioha.getQrString();
    setState(() {
      qrString = result;
      timerDuration = 30;
    });
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timerDuration > 0) {
        var result = await aioha.getQrString();
        setState(() {
          qrString = result;
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
              // Username input
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

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _loginWithHiveKeychain,
                child: const Text('Login with Hive Keychain'),
              ),
              ElevatedButton(
                onPressed: _loginWithHiveAuth,
                child: const Text('Login with HiveAuth'),
              ),

              // ✅ NEW: Login with Plaintext Key
              ElevatedButton(
                onPressed: _loginWithPlaintextKey,
                child: const Text('Login with Plaintext Key'),
              ),

              ElevatedButton(
                child: Text('Get Voting power'),
                onPressed: _getVotingPower,
              ),

              ElevatedButton(
                onPressed: _switchUser,
                child: const Text('Switch User'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String username = await aioha.getCurrentUser();
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

              // --- New Buttons for Account Authority ---
              ElevatedButton(
                onPressed: _addAccountAuthority,
                child: const Text('Add Account Authority'),
              ),
              ElevatedButton(
                onPressed: _removeAccountAuthority,
                child: const Text('Remove Account Authority'),
              ),

              // --- End New Buttons ---
              ElevatedButton(
                onPressed: _commentWithOptions,
                child: const Text('Comment with Options'),
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
      ),
    );
  }
}
