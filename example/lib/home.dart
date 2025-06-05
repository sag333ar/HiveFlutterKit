import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/community_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/ux/aioha_login_screen.dart';
import 'package:hive_flutter_kit/ux/aioha_switch_user.dart';
import 'package:hive_flutter_kit/ux/community_list.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/three_speak_feed_list.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late HiveFlutterKitPlatform aioha;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    aioha = Provider.of<HiveFlutterKitPlatform>(context, listen: false);
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

      var result = await aioha.getVotingPower(username);
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

  Future<void> _getChainPropertiesAioha() async {
    try {
      var result = await aioha.getChainProperties();
      debugPrint("Aioha Chain Properties: $result");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chain Properties: $result')));
    } catch (e) {
      debugPrint('Aioha getChainProperties error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chain Properties Error: $e')));
    }
  }

  Future<void> _getDiscussionsAioha() async {
    try {
      final result = await aioha.getDiscussions(
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
      debugPrint('Aioha getDiscussions error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Discussions Error: $e')));
    }
  }

  Future<void> _getAccountsAioha() async {
    try {
      var result = await aioha.getAccounts(['sagarkothari88']);
      for (var account in result) {
        debugPrint("Account: ${account.posting?.accountAuths}");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetched accounts (see debug output)')),
      );
    } catch (e) {
      debugPrint('Aioha getAccounts error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Accounts Error: $e')));
    }
  }

  Future<void> _getAccountPostsAioha() async {
    try {
      String username = 'sagarkothari88';
      String sort = 'comments';
      var result = await aioha.getAccountPosts(
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
      debugPrint('Aioha getAccountPosts error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get AccountPosts Error: $e')));
    }
  }

  Future<void> _getVotingPowerAioha() async {
    try {
      var result = await aioha.getVotingPower('sagarkothari88');
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
      debugPrint('Aioha getVotingPower error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Voting Power Error: $e')));
    }
  }

  Future<void> _getResourceCreditsAioha() async {
    try {
      var result = await aioha.getResourceCredits('sagarkothari88');
      debugPrint("Resources Credits Percentage: ${result.percentage}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resources Credits Percentage: ${result.percentage}'),
        ),
      );
    } catch (e) {
      debugPrint('Aioha getResourceCredits error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Get Resource Credits Error: $e')));
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
      bool hasThreespeak = await aioha.hasThreespeakInAccountAuths(username);
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

  Future<void> _fetchCommunities({bool loadMore = false}) async {
    if (_isLoadingCommunities || !_hasMoreCommunities) return;

    setState(() {
      _isLoadingCommunities = true;
    });

    try {
      final result = await aioha.getListOfCommunities(
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

  Future<void> _getCommentsListAioha() async {
    try {
      String author = 'cositav'; // Replace with actual video author
      String permlink = 'miwbidtw'; // Replace with actual video permlink

      final comments = await aioha.getCommentsList(author, permlink);

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
      debugPrint('Aioha getCommentsList error: $e');
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
      final url = await aioha.pickImageWithMaxSize(
        2000,
        "https://images.ecency.com/hs",
      );
      setState(() {
        _uploadedImageUrl = url['url'];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image uploaded: $url')));
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
      final accounts = await aioha.getAccounts([username]);
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

      final response = await aioha.signAndBroadcastTx(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              // --- AIOHA equivalents for dhive UI ---
              ElevatedButton(
                child: Text('Get Chain Properties (Aioha)'),
                onPressed: _getChainPropertiesAioha,
              ),
              ElevatedButton(
                child: Text('Get Discussions (Aioha)'),
                onPressed: _getDiscussionsAioha,
              ),
              ElevatedButton(
                child: Text('Get Accounts (Aioha)'),
                onPressed: _getAccountsAioha,
              ),
              ElevatedButton(
                child: Text('Get AccountPosts (Aioha)'),
                onPressed: _getAccountPostsAioha,
              ),
              ElevatedButton(
                child: Text('Get Voting power (Aioha)'),
                onPressed: _getVotingPowerAioha,
              ),
              ElevatedButton(
                child: Text('Resources Credits Percentage (Aioha)'),
                onPressed: _getResourceCreditsAioha,
              ),

              // --- End AIOHA equivalents ---
              ElevatedButton(
                onPressed: _checkThreespeakInAccountAuths,
                child: const Text('Check threespeak in accountAuths'),
              ),
              ElevatedButton(
                child: Text('Get Comments (Aioha)'),
                onPressed: _getCommentsListAioha,
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
                        (context) => AlertDialog(content: AiohaSwitchUser(aioha: aioha)),
                  );
                },
                child: const Text('Switch User (Dialog)'),
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
                            builder: (context) => Dialog(
                              insetPadding: EdgeInsets.zero,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: AiohaLoginScreen(aioha: aioha),
                              ),
                            ),
                          );
                        },
                        child: const Text('Aioha Login Screen User (Dialog)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
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
                                  aioha: aioha,
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('Communities List (Dialog)'),
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

              // --- ThreeSpeak Feed List Buttons ---
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Trending Feed')),
                        body: const ThreeSpeakFeedList(feedType: ThreeSpeakFeedType.trending),
                      ),
                    ),
                  );
                },
                child: const Text('Show Trending Feed'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('New Uploads Feed')),
                        body: const ThreeSpeakFeedList(feedType: ThreeSpeakFeedType.newUploads),
                      ),
                    ),
                  );
                },
                child: const Text('Show New Uploads Feed'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('First Uploads Feed')),
                        body: const ThreeSpeakFeedList(feedType: ThreeSpeakFeedType.firstUploads),
                      ),
                    ),
                  );
                },
                child: const Text('Show First Uploads Feed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
