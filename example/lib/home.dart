import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/community_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/ux/bottom_tool_bar.dart';
import 'package:hive_flutter_kit_example/ui/dialogs/video_options_dialogs.dart';
import 'package:hive_flutter_kit_example/widgets/login_form.dart';
import 'package:hive_flutter_kit_example/services/auth_service.dart';
import 'package:hive_flutter_kit_example/widgets/transfer_funds_form.dart';
import 'package:hive_flutter_kit_example/services/wallet_service.dart';
import 'package:hive_flutter_kit_example/widgets/image_uploader_widget.dart';
import 'package:hive_flutter_kit_example/services/profile_service.dart';
import 'package:hive_flutter_kit_example/widgets/qr_code_display_widget.dart';
import 'package:hive_flutter_kit_example/ui/ui_helpers.dart';
import 'package:hive_flutter_kit_example/widgets/dhive_components_widget.dart';
import 'package:hive_flutter_kit_example/widgets/threespeak_components_widget.dart'; // Added import
//import 'package:hive_flutter_ux/ux/dhive/witnesses/witnesses.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late HiveFlutterKitPlatform hfk;
  late AuthService _authService;
  late WalletService _walletService;
  late ProfileService _profileService; // Added ProfileService instance
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
  void initState() {
    super.initState();
    // hfk should be initialized either here or in didChangeDependencies before AuthService
    // Assuming hfk is initialized by didChangeDependencies first or is accessible globally for simplicity
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hfk = HiveFlutterKitPlatform.instance;
    _authService = AuthService(
      hfk: hfk,
      showSnackBar: _showSnackBar,
      startTimer: _startTimer,
      cancelHiveAuth: _cancelHiveAuth,
    );
    _walletService = WalletService(hfk: hfk, showSnackBar: _showSnackBar);
    _profileService = ProfileService(hfk: hfk, showSnackBar: _showSnackBar);
  }

  // Helper method to show snackbar, to be passed to services
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Login methods are now removed from here and are in AuthService

  // Transferred to WalletService, this method will now call the service
  Future<void> _handleTransferFunds() async {
    setState(() {
      _isTransferring = true;
      _transferResult = null;
    });

    final result = await _walletService.transferFunds(
      recipient: _transferRecipientController.text,
      amountString: _transferAmountController.text,
      assetSymbol: _transferAssetSymbol,
      memo: _transferMemoController.text,
    );

    setState(() {
      _transferResult = result;
      _isTransferring = false;
    });
  }


  // _loginWithHiveAuth and _loginWithPlaintextKey are removed as they are now in AuthService

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
      var userStatus = await hfk.getCurrentUser();
      userStatus = userStatus.replaceAll('"', '');

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

  // Image upload and broadcast methods moved to ProfileService
  Future<void> _handlePickAndUploadImage() async {
    setState(() {
      _isUploading = true; // Set uploading state before calling service
      _uploadedImageUrl = null;
    });
    final imageUrl = await _profileService.pickAndUploadImage();
    setState(() {
      _uploadedImageUrl = imageUrl;
      _isUploading = false; // Reset uploading state after service call
    });
  }

  Future<void> _handleSignAndBroadcastTx() async {
    setState(() {
      _isBroadcasting = true; // Set broadcasting state
      _broadcastResult = null;
    });
    // Assuming 'shaktimaaan' is the target username for profile update.
    // This should ideally come from the logged-in user state.
    final String currentUsername = _usernameController.text.isNotEmpty ? _usernameController.text : "shaktimaaan";
    final result = await _profileService.signAndBroadcastProfileImageTx(_uploadedImageUrl, currentUsername);
    setState(() {
      _broadcastResult = result;
      _isBroadcasting = false; // Reset broadcasting state
    });
  }

  // getVideoPlayer moved to example/lib/ui/ui_helpers.dart as buildVideoPlayerScreen

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

  // Moved _showVideoOptionsBottomSheet & _showDeleteConfirmation to example/lib/ui/dialogs/video_options_dialogs.dart

  // Callback for delete confirmation
  void _handleDeleteVideoConfirmed(String videoId) {
    print('Deleting video: $videoId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video deleted successfully (from home.dart)'),
        backgroundColor: Colors.red,
      ),
    );
    // TODO: Add actual delete logic here if needed
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
              // LoginForm
              LoginForm(
                usernameController: _usernameController,
                postingKeyController: _postingKeyController,
                onLoginWithHiveKeychain: () => _authService.loginWithHiveKeychain(_usernameController.text),
                onLoginWithHiveAuth: () => _authService.loginWithHiveAuth(_usernameController.text),
                onLoginWithPlaintextKey: () => _authService.loginWithPlaintextKey(
                  _usernameController.text,
                  _postingKeyController.text,
                ),
              ),
              // End LoginForm

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
                  var screen = buildVideoPlayerScreen( // Updated call
                    context,
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
              // --- End Basic User Actions ---

              // --- Account Authority Buttons ---
              ElevatedButton(
                onPressed: _addAccountAuthority,
                child: const Text('Add Account Authority'),
              ),
              ElevatedButton(
                onPressed: _removeAccountAuthority,
                child: const Text('Remove Account Authority'),
              ),
              // --- End Account Authority Buttons ---

              ElevatedButton(
                onPressed: _commentWithOptions, // This might be a more advanced comment action
                child: const Text('Comment with Options'),
              ),

              // --- Dhive Components Widget ---
              DhiveComponentsWidget(
                hfk: hfk,
                getChainPropertieshfk: _getChainPropertieshfk,
                getDiscussionshfk: _getDiscussionshfk,
                getAccountshfk: _getAccountshfk,
                getAccountPostshfk: _getAccountPostshfk,
                getVotingPowerhfk: _getVotingPowerhfk,
                getResourceCreditshfk: _getResourceCreditshfk,
                getFollowingsData: () => _showSnackBar("Get Followings Data (Placeholder)"), // Placeholder, original was nav
                getFollowersData: () => _showSnackBar("Get Followers Data (Placeholder)"),   // Placeholder, original was nav
                getWitnessVotesData: () => _showSnackBar("Get Witness Votes Data (Placeholder)"),// Placeholder, original was nav
                getProposalsExample: () => _showSnackBar("Get Proposals Example (Placeholder)"), // Placeholder, original was nav
                getAccountHistoryExample: () => _showSnackBar("Get Account History (Placeholder)"), // Placeholder, original was nav
                checkThreespeakInAccountAuths: _checkThreespeakInAccountAuths,
                getCommentsListhfk: _getCommentsListhfk,
                fetchCommunities: () => _fetchCommunities(loadMore: false),
                fetchMoreCommunities: (loadMore) => _fetchCommunities(loadMore: loadMore),
                communities: _communities,
                isLoadingCommunities: _isLoadingCommunities,
                hasMoreCommunities: _hasMoreCommunities,
                usernameController: _usernameController, // For checkThreespeakInAccountAuths
                showSnackBar: _showSnackBar,
                getWitnessesByVote: _getWitnessesByVote,
              ),
              // --- End Dhive Components Widget ---

              // QR Code Display Widget
              QrCodeDisplayWidget(
                qrString: qrString,
                timerDuration: timerDuration,
                onCancel: _cancelHiveAuth,
              ),
              // End QR Code Display Widget

              // --- Image Upload and Broadcast UI ---
              ImageUploaderWidget(
                uploadedImageUrl: _uploadedImageUrl,
                isUploading: _isUploading,
                onPickAndUploadImage: _handlePickAndUploadImage,
                onSignAndBroadcastTx: _handleSignAndBroadcastTx,
                isBroadcasting: _isBroadcasting,
                broadcastResult: _broadcastResult,
              ),
              // --- End Image Upload and Broadcast UI ---

              // --- Transfer UI ---
              TransferFundsForm(
                recipientController: _transferRecipientController,
                amountController: _transferAmountController,
                memoController: _transferMemoController,
                selectedAssetSymbol: _transferAssetSymbol,
                onAssetChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _transferAssetSymbol = newValue;
                    });
                  }
                },
                onTransfer: _handleTransferFunds,
                isTransferring: _isTransferring,
                transferResult: _transferResult,
              ),
              // --- End Transfer UI ---

              // --- ThreeSpeak Components Widget ---
              ThreeSpeakComponentsWidget(
                hfk: hfk,
                showSnackBar: _showSnackBar,
                videoPlayerBuilder: (ctx, author, permlink, item) => buildVideoPlayerScreen(ctx, author, permlink, item),
                showVideoOptionsSheet: (ctx, videoId) => showVideoOptionsBottomSheet(ctx, videoId, _handleDeleteVideoConfirmed),
                onUserLogout: _logout, // Assuming general logout is fine, or create a specific 3speak logout handler
              ),
              // --- End ThreeSpeak Components Widget ---

              // The Witnesses button seems more like a Dhive component, it was moved to DhiveComponentsWidget.
              // If it was intended for ThreeSpeak, it should be moved back or clarified.
            ],
          ),
        ),
      ),
    );
  }
}
