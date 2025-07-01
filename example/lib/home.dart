import 'dart:convert';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/ux/bottom_tool_bar.dart';
import 'package:hive_flutter_kit/ux/switch_user.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late HiveFlutterKitPlatform hfk;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hfk = HiveFlutterKitPlatform.instance;
  }

  @override
  void initState() {
    super.initState();
  }

  void _logout() async {
    try {
      final userStatus = await hfk.getCurrentUser();

      if (userStatus == null ||
          userStatus == '' ||
          userStatus.contains('No user is currently logged in')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is currently logged in')),
        );
        return;
      }
      await hfk.logout();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Successfully logged out')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error during logout: $e')));
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

      final result = await hfk.commentWithOptions(
        '',
        'hive-184437',
        'asdfasfaasdfsdfasdfasfasdf',
        'this is a test title from hfk comment with options',
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

  void _reblog() async {
    try {
      final result = await hfk.reblog('sagarkothari', 'rblmtojs', true);
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
      final result = await hfk.reblog('sagarkothari', 'rblmtojs', false);
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
      final result = await hfk.follow('sagarkothari', false);
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
    if (hfk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: hfk is not initialized')),
      );
      return;
    }

    try {
      final otherLogins = await hfk.getOtherLogins();
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
                          final result = await hfk.removeOtherLogin(
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
                      final result = await hfk.switchUser(selectedUser);
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
      final result = await hfk.follow('sagarkothari', true);
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
      final result = await hfk.claimRewards();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomToolbarWithSlider(
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _switchUser,
                child: const Text('Switch User'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String username = await hfk.getCurrentUser();
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
                onPressed: _commentWithOptions,
                child: const Text('Comment with Options'),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(content: SwitchUser(hfk: hfk)),
                  );
                },
                child: const Text('Switch User (Dialog)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
