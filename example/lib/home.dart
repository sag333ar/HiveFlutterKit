import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter_kit/core/common/enum.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/community_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/trending_feed_response.dart';
import 'package:hive_flutter_kit/ux/bottom_tool_bar.dart';
import 'package:hive_flutter_kit/ux/dhive/account_activities/account_activities.dart';
import 'package:hive_flutter_kit/ux/dhive/comments/hive_post_comments.dart';
import 'package:hive_flutter_kit/ux/dhive/witnesses/witnesses.dart';
import 'package:hive_flutter_kit/ux/dhive/following_followers/followers.dart';
import 'package:hive_flutter_kit/ux/dhive/following_followers/followings.dart';
import 'package:hive_flutter_kit/ux/dhive/following_followers/witness_votes.dart';
import 'package:hive_flutter_kit/ux/login_screen.dart';
import 'package:hive_flutter_kit/ux/switch_user.dart';
import 'package:hive_flutter_kit/ux/dhive/community_list/community_list.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_trending_tags.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_video_feed.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_community_screen/threespeak_commnuity_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_login_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/video_upload_screen.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/video_player.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/account_posts_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/blog_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/comments_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/community_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/account_post/replies_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/feed_screen/trending_feed_screen.dart';
import 'package:hive_flutter_kit/ux/dhive/user_profile/user_profile_picture.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:hive_flutter_ux/ux/dhive/witnesses/witnesses.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late HiveFlutterKitPlatform hfk;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _postingKeyController = TextEditingController();

  var qrString = '';
  var timerDuration = 0;

  int _communityPage = 0;
  final int _communityPageSize = 20;
  List<CommunityItem> _communities = [];
  bool _isLoadingCommunities = false;
  bool _hasMoreCommunities = true;

  String? _currentObserver;
  String? _lastCommunityName;
  String _searchQuery = '';

  String? _uploadedImageUrl;
  bool _isUploading = false;
  bool _isBroadcasting = false;
  String? _broadcastResult;

  // --- Transfer State Variables ---
  final TextEditingController _transferRecipientController =
      TextEditingController();
  final TextEditingController _transferAmountController =
      TextEditingController();
  final TextEditingController _transferMemoController = TextEditingController();
  String _transferAssetSymbol = 'HIVE'; // Default asset
  String? _transferResult;
  bool _isTransferring = false;
  // --- End Transfer State Variables ---

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hfk = HiveFlutterKitPlatform.instance;
  }

  @override
  void initState() {
    super.initState();
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

  void _transferFunds() async {
    setState(() {
      _isTransferring = true;
      _transferResult = null;
    });

    final recipient = _transferRecipientController.text;
    final amountString = _transferAmountController.text;
    final memo =
        _transferMemoController.text.isEmpty
            ? null
            : _transferMemoController.text;

    if (recipient.isEmpty) {
      setState(() {
        _transferResult = 'Error: Recipient username is required.';
        _isTransferring = false;
      });
      return;
    }

    double amount;
    try {
      amount = double.parse(amountString);
      if (amount <= 0) {
        throw FormatException('Amount must be positive');
      }
    } catch (e) {
      setState(() {
        _transferResult =
            'Error: Invalid amount. Please enter a positive number.';
        _isTransferring = false;
      });
      return;
    }

    try {
      final result = await hfk.transfer(
        recipient,
        amount,
        _transferAssetSymbol,
        memo,
      );
      setState(() {
        _transferResult = 'Success: $result';
      });
    } catch (e) {
      setState(() {
        _transferResult = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTransferring = false;
      });
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

  void _comment() async {
    try {
      final result = await hfk.comment(
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

  Future<void> _getChainPropertieshfk() async {
    try {
      var result = await hfk.getChainProperties();
      debugPrint("hfk Chain Properties: $result");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chain Properties: $result')));
    } catch (e) {
      debugPrint('hfk getChainProperties error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chain Properties Error: $e')));
    }
  }

  Future<void> _getDiscussionshfk() async {
    try {
      final result = await hfk.getDiscussions(
        'trending',
        limit: 20,
        tag: '',
        startAuthor: null,
        startPermlink: null,
        observer: '',
      );
      for (var discussion in result) {
        final metadata = discussion.jsonMetadata;
        debugPrint('--- ${discussion.title} ---');
        debugPrint('--- ${discussion.community} ---');
        debugPrint('--- ${discussion.communityTitle} ---');
        debugPrint('Uplovte Count : ${discussion.stats?.totalVotes}');
        debugPrint('App: ${metadata?.app}');
        debugPrint('Tags: ${metadata?.tags?.join(', ') ?? 'none'}');
        debugPrint(
          'First image: ${metadata?.image?.isNotEmpty == true ? metadata!.image!.first : 'none'}',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched discussions (see debug output)')),
      );
    } catch (e) {
      debugPrint('hfk getDiscussions error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Discussions Error: $e')));
    }
  }

  Future<void> _getAccountshfk() async {
    try {
      var result = await hfk.getAccounts(['sagarkothari88']);
      for (var account in result) {
        debugPrint("Account: ${account.posting?.accountAuths}");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched accounts (see debug output)')),
      );
    } catch (e) {
      debugPrint('hfk getAccounts error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Accounts Error: $e')));
    }
  }

  Future<void> _getAccountPostshfk() async {
    try {
      String username = 'sagarkothari88';
      String sort = 'comments';
      var result = await hfk.getAccountPosts(
        username,
        limit: 20,
        sort,
        // observer: 'shaktimaaan',
        // startAuthor: 'sagarkothari88',
        // startPermlink: 're-sagarkothari88-20250204t071809647',
      );
      if (result.isEmpty) {
        debugPrint('No posts found.');
      } else {
        for (var post in result) {
          debugPrint('--- Post Debug Start ---');
          debugPrint('Author: ${post.author}');
          debugPrint('Title: ${post.title}');
          debugPrint('Permlink: ${post.permlink}');
          debugPrint('Author Reputation: ${post.authorReputation}');
          debugPrint('FirstRebloggedBy: ${post.firstRebloggedBy ?? "null"}');
          debugPrint('FirstRebloggedOn: ${post.firstRebloggedOn ?? "null"}');
          debugPrint('PendingPayoutValue: ${post.pendingPayoutValue}');
          debugPrint(
            'TotalPendingPayoutValue: ${post.totalPendingPayoutValue}',
          );
          debugPrint('Promoted: ${post.promoted}');
          debugPrint('RootTitle: ${post.rootTitle}');
          debugPrint('URL: ${post.url}');
          debugPrint('ActiveVotes Count: ${post.activeVotes?.length ?? 0}');
          debugPrint('Replies Count: ${post.replies?.length ?? 0}');
          debugPrint('RebloggedBy Count: ${post.rebloggedBy?.length ?? 0}');
          debugPrint('Beneficiaries Count: ${post.beneficiaries?.length ?? 0}');
          debugPrint('Payout : ${post.payout ?? 0}');
          debugPrint('Uplovte Count : ${post.stats?.totalVotes}');
          debugPrint('--- Post Debug End ---\n');
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched account posts (see debug output)')),
      );
    } catch (e) {
      debugPrint('hfk getAccountPosts error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get AccountPosts Error: $e')));
    }
  }

  Future<void> _getVotingPowerhfk() async {
    try {
      var result = await hfk.getVotingPower('sagarkothari88');
      debugPrint(
        "Voting Power: ${result.downvotePower}, ${result.upvotePower}",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Voting Power: ${result.downvotePower}, ${result.upvotePower}',
          ),
        ),
      );
    } catch (e) {
      debugPrint('hfk getVotingPower error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Voting Power Error: $e')));
    }
  }

  Future<void> _getResourceCreditshfk() async {
    try {
      var result = await hfk.getResourceCredits('sagarkothari88');
      debugPrint("Resources Credits Percentage: ${result.percentage}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resources Credits Percentage: ${result.percentage}'),
        ),
      );
    } catch (e) {
      debugPrint('hfk getResourceCredits error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Resource Credits Error: $e')));
    }
  }

  Future<void> _getFollowingsData() async {
    try {
      var result = await hfk.getFollowingsData(
        'sagarkothari88', // username
        start: '', // optional
        type: 'blog', // optional
        limit: 100, // optional
      );

      debugPrint("Followings Count: ${result.count}");
      for (var user in result.followings ?? []) {
        debugPrint("Following: ${user['following']}");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched ${result.count} followings')),
      );
    } catch (e) {
      debugPrint('getFollowingsData error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get followings')));
    }
  }

  Future<void> _getFollowersData() async {
    try {
      var result = await hfk.getFollowersData(
        'sagarkothari88', // username
        start: '', // optional
        type: 'blog', // optional
        limit: 100, // optional
      );

      debugPrint("Followers Count: ${result.count}");
      for (var user in result.followers ?? []) {
        debugPrint("Follower: ${user['follower']}");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched ${result.count} followers')),
      );
    } catch (e) {
      debugPrint('getFollowersData error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get followers')));
    }
  }

  Future<void> _getWitnessVotesData() async {
    try {
      var result = await hfk.getWitnessVotesData('sagarkothari88');

      for (var witness in result.witnessVotes ?? []) {
        debugPrint("Voted for: $witness");
      }
      debugPrint("Voted count: ${result.witnessesVotedFor ?? 0}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Witnesses voted for: ${result.witnessesVotedFor ?? 0}',
          ),
        ),
      );
    } catch (e) {
      debugPrint('getWitnessVotesData error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get witness votes')));
    }
  }
  
  Future<void> _getAccountHistoryExample() async {
    try {
      String account = 'sagarkothari88';
      int index = -1; // latest
      int limit = 100; // fetch last 100 operations
      String? start = null;
      String? stop = null;

      final result = await hfk.getAccountHistory(
        account,
        index: index,
        limit: limit,
        start: start,
        stop: stop,
      );

      if (result.isEmpty) {
        debugPrint('No account history found.');
      } else {
        for (var op in result) {
          debugPrint('--- History Op Start ---');
          debugPrint('Index: ${op.index}');
          final detail = op.detail;

          debugPrint('Block: ${detail?.block}');
          debugPrint('Transaction ID: ${detail?.trxId}');
          debugPrint('Timestamp: ${detail?.timestamp}');
          debugPrint('Virtual Op: ${detail?.virtualOp}');
          if (detail?.op != null && detail!.op!.length == 2) {
            debugPrint('Operation Type: ${detail.op![0]}');
            debugPrint('Operation Payload: ${jsonEncode(detail.op![1])}');
          } else {
            debugPrint('Operation: null or malformed');
          }
          debugPrint('--- History Op End ---\n');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched account history (see debug output)')),
      );
    } catch (e) {
      debugPrint('Error in getAccountHistory: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Account History Error: $e')));
    }
  }

  Future<void> _getProposalsExample() async {
    try {
      final result = await hfk.getProposals(
        start: [-1],
        limit: 100,
        order: 'by_total_votes',
        orderDirection: 'descending',
        status: 'votable',
      );
      // Example: Print the number of proposals fetched
      debugPrint('Fetched ${result.length} proposals');
      if (result.isEmpty) {
        debugPrint('No proposals found.');
      } else {
        for (var proposal in result) {
          debugPrint('--- Proposal Start ---');
          debugPrint('ID: ${proposal.id}');
          debugPrint('Proposal ID: ${proposal.proposalId}');
          debugPrint('Creator: ${proposal.creator}');
          debugPrint('Receiver: ${proposal.receiver}');
          debugPrint('Subject: ${proposal.subject}');
          debugPrint('Permlink: ${proposal.permlink}');
          debugPrint(
            'Daily Pay: ${proposal.dailyPay.amount} ${proposal.dailyPay.nai}',
          );
          debugPrint('Start Date: ${proposal.startDate}');
          debugPrint('End Date: ${proposal.endDate}');
          debugPrint('Total Votes: ${proposal.totalVotes}');
          debugPrint('Status: ${proposal.status}');
          debugPrint('--- Proposal End ---\n');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched proposals (see debug output)')),
      );
    } catch (e) {
      debugPrint('Error in getProposals: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Proposals Error: $e')));
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

  void _cancelHiveAuth() {
    setState(() {
      qrString = '';
      timerDuration = 0;
    });
  }

  Future<void> _fetchCommunities({bool loadMore = false}) async {
    if (_isLoadingCommunities || !_hasMoreCommunities) return;

    setState(() {
      _isLoadingCommunities = true;
    });

    try {
      final result = await hfk.getListOfCommunities(
        _searchQuery.isNotEmpty ? _searchQuery : null,
        limit: _communityPageSize,
        last: loadMore ? _lastCommunityName : null,
        observer: _currentObserver, // optional, nullable
      );

      if (result.isEmpty) {
        setState(() {
          _hasMoreCommunities = false;
        });
      } else {
        setState(() {
          if (loadMore) {
            _communities.addAll(result);
          } else {
            _communities = result;
          }
          _lastCommunityName = result.last.name;
          _hasMoreCommunities = result.length == _communityPageSize;
          _communityPage += 1;
        });
      }

      debugPrint('Communities: ${_communities.map((c) => c.name).join(', ')}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched ${result.length} communities')),
      );
    } catch (e) {
      debugPrint('Error fetching communities: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching communities: $e')));
    } finally {
      setState(() {
        _isLoadingCommunities = false;
      });
    }
  }

  Future<void> _getCommentsListhfk() async {
    try {
      String author = 'cositav'; // Replace with actual video author
      String permlink = 'miwbidtw'; // Replace with actual video permlink

      final comments = await hfk.getCommentsList(author, permlink);

      if (comments.isEmpty) {
        debugPrint('No comments found.');
      } else {
        debugPrint('--- Comments Start ---');
        for (var comment in comments) {
          debugPrint('Author: ${comment.author}');
          debugPrint('Body: ${comment.body}'); // Full comment
          debugPrint('Permlink: ${comment.permlink}');
          debugPrint('Reputation: ${comment.authorReputation}');
          debugPrint('---');
        }
        debugPrint('--- Comments End ---');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched ${comments.length} comments')),
      );
    } catch (e) {
      debugPrint('hfk getCommentsList error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Comments Error: $e')));
    }
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      // _isUploading = true;
      _uploadedImageUrl = null;
    });
    try {
      final res = await hfk.pickImageWithMaxSize(
        2000,
        "https://images.ecency.com/hs",
      );
      setState(() {
        _uploadedImageUrl = res.url;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image uploaded: ${res.url}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _signAndBroadcastTx() async {
    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first')),
      );
      return;
    }

    setState(() {
      _isBroadcasting = true;
      _broadcastResult = null;
    });

    try {
      // Fetch account and decode posting_json_metadata
      final username = "shaktimaaan";
      final accounts = await hfk.getAccounts([username]);
      if (accounts.isEmpty) throw Exception("Account not found");

      final account = accounts.first;
      final postingJsonMetadataStr = account.postingJsonMetadata;
      if (postingJsonMetadataStr == null || postingJsonMetadataStr.isEmpty) {
        throw Exception("No posting_json_metadata found for account");
      }

      // Decode and update profile_image
      final postingJsonMetadata = jsonDecode(postingJsonMetadataStr);
      if (postingJsonMetadata is! Map<String, dynamic>) {
        throw Exception("Invalid posting_json_metadata format");
      }

      // Update profile_image
      if (postingJsonMetadata.containsKey('profile') &&
          postingJsonMetadata['profile'] is Map<String, dynamic>) {
        postingJsonMetadata['profile']['profile_image'] = _uploadedImageUrl;
      }

      print(
        'Updated profile_image: ${postingJsonMetadata['profile']['profile_image']}',
      );

      // Prepare operation data as dynamic
      final operationData = {
        "account": username,
        "json_metadata": "",
        "posting_json_metadata": jsonEncode(postingJsonMetadata),
        "extensions": [],
      };

      // Use dynamic for operation and operationRequest
      final dynamic operation = ["account_update2", operationData];
      final dynamic operationRequest = [operation];

      final response = await hfk.signAndBroadcastTx(
        operationRequest,
        'posting',
      );

      // Handle response as dynamic
      if (response != null && response['success'] == true) {
        setState(() {
          _broadcastResult =
              response['profile']?['profile_image'] ??
              'Broadcasted successfully!';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Broadcast Success')));
      } else {
        setState(() {
          _broadcastResult =
              'Broadcast failed: ${response?['error'] ?? 'Unknown error'}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Broadcast failed: ${response?['error'] ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _broadcastResult = 'Broadcast failed: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Broadcast failed: $e')));
    } finally {
      setState(() {
        _isBroadcasting = false;
      });
    }
  }

  VideoPlayerScreen getVideoPlayer(
    String? author,
    String? permlink,
    GQLFeedItem? item,
  ) {
    return VideoPlayerScreen(
      item: item,
      author: author, //'ninaeatshere',
      permlink: permlink, // 'movrcxlslz',
      onTapBackButton: () {
        Navigator.pop(context);
      },
      shouldShowBackButton: true,
      videoFeed: () {
        return ThreeSpeakVideoFeed(
          feedType: ThreeSpeakVideoFeedType.related,
          onTapVideoItem: (tappedItem) {
            var screen = getVideoPlayer(null, null, tappedItem);
            var route = MaterialPageRoute(builder: (context) => screen);
            Navigator.push(context, route);
          },
          relatedAuthor: 'ninaeatshere',
          relatedPermlink: 'movrcxlslz',
          onTapAuthor: (GQLFeedItem item) {
            debugPrint('Tapped author: ${item.author}');
          },
          onTapReport: (GQLFeedItem item) {
            debugPrint('Tapped report: ${item.permlink}');
          },
          onTapUpvote: (GQLFeedItem item) {
            debugPrint('Tapped upvote: ${item.permlink}');
          },
          onTapComment: (GQLFeedItem item) {
            debugPrint('Tapped comment: ${item.permlink}');
          },
        );
      },
    );
  }

  Future<void> _getWitnessesByVote() async {
    try {
      final result = await hfk.getWitnessesByVote(limit: 10);
      //debugPrint('Witnesses by vote: ${result.map((w) => w.owner).join(', ')}');
      debugPrint('Witnesses by vote: ${result.map((w) => w.name).join(', ')}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched ${result.length} witnesses')),
      );
    } catch (e) {
      debugPrint('Error fetching witnesses by vote: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                onPressed: () {
                  var screen = getVideoPlayer(
                    "ninaeatshere",
                    "movrcxlslz",
                    null,
                  );
                  var route = MaterialPageRoute(builder: (context) => screen);
                  Navigator.push(context, route);
                },
                child: const Text('video player'),
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

              // --- hfk equivalents for dhive UI ---
              ElevatedButton(
                child: Text('Get Chain Properties (hfk)'),
                onPressed: _getChainPropertieshfk,
              ),
              ElevatedButton(
                child: Text('Get Discussions (hfk)'),
                onPressed: _getDiscussionshfk,
              ),
              ElevatedButton(
                child: Text('Get Accounts (hfk)'),
                onPressed: _getAccountshfk,
              ),
              ElevatedButton(
                child: Text('Get AccountPosts (hfk)'),
                onPressed: _getAccountPostshfk,
              ),
              ElevatedButton(
                child: Text('Get Voting power (hfk)'),
                onPressed: _getVotingPowerhfk,
              ),
              ElevatedButton(
                child: Text('Resources Credits Percentage (hfk)'),
                onPressed: _getResourceCreditshfk,
              ),
              
              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Followings(
                        hfk: hfk,
                        account: 'sagarkothari88',))
                      );
                },
                //_getFollowingsData,
                child: Text("Get Followings"),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Followers(
                        hfk: hfk,
                        account: 'sagarkothari88',))
                      );
                },
                //_getFollowersData,
                child: Text("Get Followers"),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WitnessVotes(
                        hfk: hfk,
                        account: 'sagarkothari88',))
                      );
                },
                //_getWitnessVotesData,
                child: Text("Get Witness Votes"),
              ),

              ElevatedButton(
                onPressed: _getProposalsExample,
                child: Text('Get Proposals'),
              ),

              ElevatedButton(
                child: Text('Get Account History'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AccountActivities(
                            hfk: hfk,
                            account: 'sagarkothari88',
                            isFilter: true,
                          ),
                    ),
                  );
                },
              ),

              // --- End hfk equivalents ---
              ElevatedButton(
                onPressed: _checkThreespeakInAccountAuths,
                child: const Text('Check threespeak in accountAuths'),
              ),
              ElevatedButton(
                child: Text('Get Comments (hfk)'),
                onPressed: _getCommentsListhfk,
              ),
              ElevatedButton(
                onPressed: () {
                  _communityPage = 0;
                  _hasMoreCommunities = true;
                  _lastCommunityName = null;
                  _fetchCommunities(loadMore: false);
                },
                child: const Text('Fetch Communities'),
              ),
              if (_communities.isNotEmpty)
                Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _communities.length,
                      itemBuilder: (context, index) {
                        final c = _communities[index];
                        return ListTile(
                          title: Text(c.title ?? c.name ?? ''),
                          subtitle: Text(c.about ?? ''),
                        );
                      },
                    ),
                    if (_hasMoreCommunities)
                      ElevatedButton(
                        onPressed: () => _fetchCommunities(loadMore: true),
                        child:
                            _isLoadingCommunities
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Load More'),
                      ),
                  ],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: CommunityScreen(
                                  hfk: hfk,
                                  sortBy: 'trending',
                                  tag: 'hive-163772',
                                  onTap: (discussion) async {
                                    final url = discussion.url;
                                    if (url != null) {
                                      final fullUrl = Uri.parse(
                                        'https://hive.blog$url',
                                      );
                                      if (await canLaunchUrl(fullUrl)) {
                                        await launchUrl(
                                          fullUrl,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        debugPrint('Could not launch $fullUrl');
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Community (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CommunityScreen(
                                hfk: hfk,
                                sortBy: 'hot',
                                tag: 'hive-163772',
                                onTap: (discussion) async {
                                  final url = discussion.url;
                                  if (url != null) {
                                    final fullUrl = Uri.parse(
                                      'https://hive.blog$url',
                                    );
                                    if (await canLaunchUrl(fullUrl)) {
                                      await launchUrl(
                                        fullUrl,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      debugPrint('Could not launch $fullUrl');
                                    }
                                  }
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Community'),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: AccountPostsScreen(
                                  hfk: hfk,
                                  account: 'sagarkothari88',
                                  onTap: (discussion) {
                                    debugPrint(
                                      'Tapped on: ${discussion.title}',
                                    );
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Posts (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AccountPostsScreen(
                                hfk: hfk,
                                account: 'sagarkothari88',
                                onTap: (discussion) {
                                  debugPrint('Tapped on: ${discussion.title}');
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Posts'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: CommentsScreen(
                                  hfk: hfk,
                                  account: 'sagarkothari88',
                                  onTap: (discussion) {
                                    debugPrint(
                                      'Tapped comment: ${discussion.title}',
                                    );
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Comments (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CommentsScreen(
                                hfk: hfk,
                                account: 'sagarkothari88',
                                onTap: (discussion) {
                                  debugPrint(
                                    'Tapped comment: ${discussion.title}',
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Comments'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: BlogScreen(
                                  hfk: hfk,
                                  account: 'sagarkothari88',
                                  onTap: (discussion) {
                                    debugPrint(
                                      'Tapped on blog: ${discussion.title}',
                                    );
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Blog (Dialog)'),
                  ),
                  SizedBox(width: 20),
                  Text("Or"),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BlogScreen(
                                hfk: hfk,
                                account: 'techcoderx',
                                onTap: (discussion) {
                                  debugPrint(
                                    'Tapped on blog: ${discussion.title}',
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Blog'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: RepliesScreen(
                                  hfk: hfk,
                                  account: 'sagarkothari88',
                                  onTap: (discussion) {
                                    debugPrint(
                                      'Tapped reply: ${discussion.title}',
                                    );
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Replies (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => RepliesScreen(
                                hfk: hfk,
                                account: 'sagarkothari88',
                                onTap: (discussion) {
                                  debugPrint(
                                    'Tapped reply: ${discussion.title}',
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Replies'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                child: TrendingFeedScreen(
                                  hfk: hfk,
                                  onTap: (discussion) {
                                    debugPrint(
                                      'Tapped feed item: ${discussion.title}',
                                    );
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Feed (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => TrendingFeedScreen(
                                hfk: hfk,
                                onTap: (discussion) {
                                  debugPrint(
                                    'Tapped feed item: ${discussion.title}',
                                  );
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Feed'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: UserProfilePicture(
                                    username: 'sagarkothari88',
                                    hfk: hfk,
                                    showDetails: true,
                                    onTap: () {
                                      debugPrint('Profile picture tapped!');
                                    },
                                  ),
                                ),
                              ),
                            ),
                      );
                    },
                    child: const Text('Show Profile (Dialog)'),
                  ),
                  const SizedBox(width: 20),
                  const Text("Or"),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => Scaffold(
                                appBar: AppBar(
                                  title: const Text('User Profile'),
                                ),
                                body: Center(
                                  child: UserProfilePicture(
                                    username: 'sagarkothari88',
                                    hfk: hfk,
                                    // showDetails: true,
                                    // showBars:false,
                                    // onTap: () {
                                    //   debugPrint('Tapped from full screen');
                                    // },
                                  ),
                                ),
                              ),
                        ),
                      );
                    },
                    child: const Text('Go to Profile'),
                  ),
                ],
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
                    const SizedBox(width: 8),
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
                                    child: CommunitiesList(
                                      onSelectCommunity: (community) async {
                                        debugPrint(
                                          'Selected community: ${community.name}',
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      hfk: hfk,
                                    ),
                                  ),
                                ),
                          );
                        },
                        child: const Text('Communities List'),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
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
                                  child: ThreeSpeakLoginScreen(
                                    hfk: hfk,
                                    uponLogin: (context, token, username) {
                                      debugPrint(
                                        'Logged in with token: $token, username: $username',
                                      );
                                      // Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ),
                        );
                      },
                      child: const Text(
                        'ThreeSpeak Login Screen User (Dialog)',
                      ),
                    ),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HivePostComments(
                            author: 'sagarkothari88', // Example author
                            permlink: 'fuhitntzfw', // Example permlink
                          ),
                    ),
                  );
                },
                child: const Text('Show HivePostComments'),
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

              // --- Image Upload and Broadcast UI ---
              const SizedBox(height: 24),
              const Text(
                'Upload Profile Image and Broadcast Operation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_uploadedImageUrl != null)
                Image.network(_uploadedImageUrl!, width: 120, height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isUploading ? null : _pickAndUploadImage,
                    child:
                        _isUploading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Pick & Upload Image'),
                  ),
                ],
              ),
              if (_uploadedImageUrl != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Uploaded URL: $_uploadedImageUrl',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ElevatedButton(
                onPressed:
                    (_uploadedImageUrl != null && !_isBroadcasting)
                        ? _signAndBroadcastTx
                        : null,
                child:
                    _isBroadcasting
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Sign & Broadcast Tx'),
              ),
              if (_broadcastResult != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Broadcast Result: $_broadcastResult',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const Divider(),

              // --- Transfer UI ---
              const SizedBox(height: 24),
              const Text(
                'Transfer Funds (Aioha)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: TextField(
                  controller: _transferRecipientController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Username',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: TextField(
                  controller: _transferAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (e.g., 1.0)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: DropdownButtonFormField<String>(
                  value: _transferAssetSymbol,
                  decoration: const InputDecoration(
                    labelText: 'Asset',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      <String>['HIVE', 'HBD'].map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _transferAssetSymbol = newValue;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: TextField(
                  controller: _transferMemoController,
                  decoration: const InputDecoration(
                    labelText: 'Memo (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isTransferring ? null : _transferFunds,
                child:
                    _isTransferring
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Transfer Funds'),
              ),
              if (_transferResult != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Transfer Result: $_transferResult',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const Divider(),
              // --- End Transfer UI ---

              // --- ThreeSpeak Feed List Buttons ---
              const SizedBox(height: 16),
              const Text(
                'ThreeSpeak Video Feeds',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VideoUploadScreen(
                            owner: 'shaktimaaan',
                            token: "REMOVED",
                            onUploadSuccess: (response) {
                              // Handle the response object here
                              print('Upload success: $response');
                              // You can update state, show a dialog, etc.
                            },
                          ),
                    ),
                  );
                },
                child: const Text('Upload Video'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Scaffold(
                            appBar: AppBar(title: const Text('Trending Feed')),
                            body: ThreeSpeakVideoFeed(
                              feedType: ThreeSpeakVideoFeedType.trending,
                              onTapVideoItem: (tappedItem) {
                                debugPrint('Tapped video item: $tappedItem');
                                var screen = getVideoPlayer(
                                  null,
                                  null,
                                  tappedItem,
                                );
                                var route = MaterialPageRoute(
                                  builder: (context) => screen,
                                );
                                Navigator.push(context, route);
                              },
                              onTapAuthor: (GQLFeedItem item) {
                                debugPrint('Tapped author: ${item.author}');
                              },
                              onTapReport: (GQLFeedItem item) {
                                debugPrint('Tapped report: ${item.permlink}');
                              },
                              onTapUpvote: (GQLFeedItem item) {
                                debugPrint('Tapped upvote: ${item.permlink}');
                              },
                              onTapComment: (GQLFeedItem item) {
                                debugPrint('Tapped comment: ${item.permlink}');
                              },
                            ),
                          ),
                    ),
                  );
                },
                child: const Text('Show Trending Feed'),
              ),

              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder:
              //             (context) => Scaffold(
              //               appBar: AppBar(
              //                 title: const Text('New Uploads Feed'),
              //               ),
              //               body: ThreeSpeakFeedList(
              //                 feedType: ThreeSpeakFeedType.newUploads,
              //                 onTapVideoItem: (item) {
              //                   final videoUrl = getVideoUrl(item);
              //                   Navigator.push(
              //                     context,
              //                     MaterialPageRoute(
              //                       builder:
              //                           (context) => VideoPlayerScreen(
              //                             videoUrl: videoUrl ?? '',
              //                             title: item.title ?? 'Untitled',
              //                             author:
              //                                 item.author?.username ??
              //                                 'Unknown',
              //                             permlink: item.permlink ?? 'Unknown',
              //                             createdAt: item.createdAt,
              //                             item: item,
              //                           ),
              //                     ),
              //                   );
              //                 },
              //               ),
              //             ),
              //       ),
              //     );
              //   },
              //   child: const Text('Show New Uploads Feed'),
              // ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder:
              //             (context) => Scaffold(
              //               appBar: AppBar(
              //                 title: const Text('First Uploads Feed'),
              //               ),
              //               body: ThreeSpeakFeedList(
              //                 feedType: ThreeSpeakFeedType.firstUploads,
              //                 onTapVideoItem: (item) {
              //                   final videoUrl = getVideoUrl(item);
              //                   Navigator.push(
              //                     context,
              //                     MaterialPageRoute(
              //                       builder:
              //                           (context) => VideoPlayerScreen(
              //                             videoUrl: videoUrl ?? '',
              //                             title: item.title ?? 'Untitled',
              //                             author:
              //                                 item.author?.username ??
              //                                 'Unknown',
              //                             permlink: item.permlink ?? 'Unknown',
              //                             createdAt: item.createdAt,
              //                             item: item,
              //                           ),
              //                     ),
              //                   );
              //                 },
              //               ),
              //             ),
              //       ),
              //     );
              //   },
              //   child: const Text('Show First Uploads Feed'),
              // ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ThreeSpeakVideoFeed(
                            feedType: ThreeSpeakVideoFeedType.search,
                            isSearch: true,
                            onTapVideoItem: (tappedItem) {
                              debugPrint('Tapped video item: $tappedItem');
                            },
                            onTapAuthor: (GQLFeedItem item) {
                              debugPrint('Tapped author: ${item.author}');
                            },
                            onTapReport: (GQLFeedItem item) {
                              debugPrint('Tapped report: ${item.permlink}');
                            },
                            onTapUpvote: (GQLFeedItem item) {
                              debugPrint('Tapped upvote: ${item.permlink}');
                            },
                            onTapComment: (GQLFeedItem item) {
                              debugPrint('Tapped comment: ${item.permlink}');
                            },
                          ),
                    ),
                  );
                },
                child: const Text('Search screen'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ThreespeakCommnuityScreen(
                            communityId: 'hive-163772',
                            title: 'Worldmappin',
                            onTapVideoItem: (item) {
                              debugPrint('Tapped video item: ${item.title}');
                            },
                            videoFeed: () {
                              return ThreeSpeakVideoFeed(
                                feedType: ThreeSpeakVideoFeedType.commnuityFeed,
                                commnuityId: 'hive-163772',
                                onTapVideoItem: (tappedItem) {
                                  debugPrint('Tapped video item: $tappedItem');
                                },
                                onTapAuthor: (GQLFeedItem item) {
                                  debugPrint('Tapped author: ${item.author}');
                                },
                                onTapReport: (GQLFeedItem item) {
                                  debugPrint('Tapped report: ${item.permlink}');
                                },
                                onTapUpvote: (GQLFeedItem item) {
                                  debugPrint('Tapped upvote: ${item.permlink}');
                                },
                                onTapComment: (GQLFeedItem item) {
                                  debugPrint(
                                    'Tapped comment: ${item.permlink}',
                                  );
                                },
                              );
                            },
                            // Optionally add onTapAuthor, onTapVideosTab, etc.
                          ),
                    ),
                  );
                },
                child: const Text('Show 3Speak Community Screen'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ThreeSpeakTrendingTags(
                            onTapTag: (tag) {
                              debugPrint('Tapped tag: $tag');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ThreeSpeakVideoFeed(
                                        feedType:
                                            ThreeSpeakVideoFeedType
                                                .trendingTagFeed,
                                        onTapVideoItem: (tappedItem) {
                                          debugPrint(
                                            'Tapped video item: $tappedItem',
                                          );
                                        },
                                        onTapAuthor: (onTapAuthor) {},
                                        onTapReport: (onTapReport) {},
                                        onTapUpvote: (onTapUpvote) {},
                                        onTapComment: (onTapComment) {},
                                      ),
                                ),
                              );
                            },
                          ),
                    ),
                  );
                },
                child: const Text('trending tags'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Witnesses(
                            hfk: hfk,
                            onTapWitness:
                                (account) => print("Tapped on ${account.name}"),
                            onTapLink:
                                (account) =>
                                    print("Link clicked for ${account.name}"),
                            onTapCheckmark:
                                (account) => print(
                                  "Checkmark tapped for ${account.name}",
                                ),
                          ),
                    ),
                  );
                },
                //_getWitnessesByVote,
                child: const Text('Get Witnesses By Vote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
