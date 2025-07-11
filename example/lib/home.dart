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
import 'package:hive_flutter_kit_example/widgets/threespeak_components_widget.dart';
import 'package:hive_flutter_kit_example/services/dhive_service.dart';
import 'package:hive_flutter_kit_example/services/threespeak_service.dart'; // Import ThreeSpeakService
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
  late ProfileService _profileService;
  late DhiveService _dhiveService;
  late ThreeSpeakService _threeSpeakService; // Add ThreeSpeakService instance
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
      initiateQrDisplay: _initiateQrDisplay, // Pass new callback
      clearQrDisplay: _clearQrDisplay,     // Pass new callback
    );
    _walletService = WalletService(hfk: hfk, showSnackBar: _showSnackBar);
    _profileService = ProfileService(hfk: hfk, showSnackBar: _showSnackBar);
    _dhiveService = DhiveService(
      hfk: hfk,
      showSnackBar: _showSnackBar,
      initiateQrDisplay: _initiateQrDisplay, // Pass new callback
      clearQrDisplay: _clearQrDisplay,     // Pass new callback
    );
    _threeSpeakService = ThreeSpeakService(
      hfk: hfk,
      showSnackBar: _showSnackBar,
    );
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

  // All Hive direct interaction methods like _getVotingPower, _logout, etc., are now removed.
  // Their logic is in DhiveService and they are called via _dhiveService instance.

  // _checkThreespeakInAccountAuths has been moved to ThreeSpeakService.
  // The local method is now removed.

  // _startTimer and _cancelHiveAuth are passed to AuthService and DhiveService constructor
  // for them to call. The state update (qrString, timerDuration) happens here.
  // Timer object needs to be managed to be cancellable.
  Timer? _qrRefreshTimer;

  void _initiateQrDisplay(String initialQrString) {
    _qrRefreshTimer?.cancel(); // Cancel any existing timer

    if (mounted) {
      setState(() {
        qrString = initialQrString;
        timerDuration = 30; // Reset timer duration
      });
    }

    _qrRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timerDuration > 0) {
        // The QR string might be dynamic and refresh itself via the platform plugin's native view,
        // or hfk.getQrString() might be needed if it changes over time.
        // For now, assume the initial QR string is what we display, and the timer is just a countdown.
        // If hfk.getQrString() is needed for refresh, it should be called here.
        // var currentQr = await hfk.getQrString(); // Example if refresh is needed
        if (mounted) {
          setState(() {
            // qrString = currentQr; // Update if QR string itself refreshes
            timerDuration--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            qrString = ''; // Clear QR when timer expires
            timerDuration = 0;
          });
        }
      }
    });
  }

  void _clearQrDisplay() {
    _qrRefreshTimer?.cancel();
    if (mounted) {
      setState(() {
        qrString = '';
        timerDuration = 0;
      });
    }
  }

  // Image upload and broadcast methods are already in ProfileService.
  // _handlePickAndUploadImage and _handleSignAndBroadcastTx call ProfileService and manage UI state.
  Future<void> _handlePickAndUploadImage() async {
    setState(() {
      _isUploading = true;
      _uploadedImageUrl = null;
    });
    final imageUrl = await _profileService.pickAndUploadImage();
    if(mounted) {
      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploading = false;
      });
    }
  }

  Future<void> _handleSignAndBroadcastTx() async {
    setState(() {
      _isBroadcasting = true;
      _broadcastResult = null;
    });
    final String currentUsername = _usernameController.text.isNotEmpty ? _usernameController.text : "shaktimaaan"; // Example
    final result = await _profileService.signAndBroadcastProfileImageTx(_uploadedImageUrl, currentUsername);
    if(mounted) {
      setState(() {
        _broadcastResult = result;
        _isBroadcasting = false;
      });
    }
  }

  // getVideoPlayer is a UI helper, correctly placed.
  // _handleDeleteVideoConfirmed is a UI callback, correctly placed.
  // The methods _getCommentsListhfk, _fetchCommunities, _getWitnessesByVote were removed as their direct calls
  // are now part of DhiveService, and DhiveComponentsWidget calls them via _dhiveService.
  // The wrappers _handleFetchCommunities is kept to manage state.

  // Callback for delete confirmation
  void _handleDeleteVideoConfirmed(String videoId) {
    print('Deleting video: $videoId');
    _showSnackBar('Video deleted successfully (from home.dart)');
    // TODO: Add actual delete logic here if needed
  }

  // Wrapper for _dhiveService.commentWithOptions
  void _handleCommentWithOptions() {
    final jsonMetadata = {
      "tags": ["sagar", "kothari"],
      "app": "checkinwithxyz/1.0.0",
      "username": "sagar",
      "image": ["https://canopas-blogs.s3.ap-south-1.amazonaws.com/my_profile_c0f157624c.jpeg"],
      "onboarder": "sagarkothari",
      "introductionText": "Hello, I am a new user",
      "communityName": "blabla",
      "lightningAddress": "bla@bla.v4v.app",
    };
    final Map<String, dynamic> options = {
      "author": "shaktimaaan",
      "permlink": "asdfasfaasdfsdfasdfasfasdf", // This should be unique
      "allow_votes": true,
      "max_accepted_payout": "100000.000 SBD",
      "percent_hbd": 10000,
      "allow_curation_rewards": true,
      "extensions": [
        [0, {"beneficiaries": [{"weight": 3000, "account": "threespeakselfie"}]}],
      ],
    };
    _dhiveService.commentWithOptions(
      parentAuthor: '', // Or actual parent author
      parentPermlink: 'hive-184437', // Or actual parent permlink
      permlink: 'asdfasfaasdfsdfasdfasfasdf-${DateTime.now().millisecondsSinceEpoch}', // Ensure permlink is unique
      title: 'this is a test title from hfk comment with options via DhiveService',
      body: 'I am going to try this comment with options via DhiveService and see how it works.',
      jsonMetadataStr: jsonEncode(jsonMetadata),
      optionsStr: jsonEncode(options),
    );
  }

  // Wrapper for fetching communities
  Future<void> _handleFetchCommunities({bool loadMore = false}) async {
    if (_isLoadingCommunities || (!loadMore && !_hasMoreCommunities && _communities.isNotEmpty)) return;

    setState(() {
      _isLoadingCommunities = true;
      if (!loadMore) {
        _communities = []; // Clear list for a new search/initial fetch
        _communityPage = 0;
        _lastCommunityName = null;
        _hasMoreCommunities = true; // Reset for new search
      }
    });

    final result = await _dhiveService.fetchCommunities(
      _searchQuery.isNotEmpty ? _searchQuery : null,
      _communityPageSize,
      loadMore ? _lastCommunityName : null,
      _currentObserver,
    );

    if (mounted) {
      setState(() {
        if (result.isEmpty) {
          _hasMoreCommunities = false;
        } else {
          if (loadMore) {
            _communities.addAll(result);
          } else {
            _communities = result;
          }
          _lastCommunityName = result.isNotEmpty ? result.last.name : null;
          _hasMoreCommunities = result.length == _communityPageSize;
          if (result.isNotEmpty && !loadMore) _communityPage = 1;
          else if (result.isNotEmpty && loadMore) _communityPage++;
        }
        _isLoadingCommunities = false;
      });
    }
  }

  // Wrapper for _dhiveService.switchUser and related dialog
  Future<void> _handleSwitchUser() async {
    if (hfk == null) { // hfk instance check, though _dhiveService also has it
      _showSnackBar('Error: Component not initialized properly');
      return;
    }

    final otherLogins = await _dhiveService.getOtherLogins();
    if (otherLogins.isEmpty) {
      _showSnackBar('No other logged-in users available');
      return;
    }

    if (!mounted) return; // Check if the widget is still in the tree

    await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) { // Use a different context name
        return AlertDialog(
          title: const Text('Manage Logged-in Users'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: otherLogins.length,
              itemBuilder: (context, index) {
                final user = otherLogins[index];
                return ListTile(
                  title: Text(user),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      await _dhiveService.performRemoveOtherLogin(user);
                      Navigator.of(dialogContext).pop(); // Close dialog
                      // Optionally, refresh user list or UI
                    },
                  ),
                  onTap: () async {
                    await _dhiveService.performSwitchUser(user);
                    Navigator.of(dialogContext).pop(); // Close dialog
                     // Optionally, refresh user data on UI
                  },
                );
              },
            ),
          ),
        );
      },
    );
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
                onPressed: () => _dhiveService.getVotingPower(_usernameController.text),
              ),

              ElevatedButton(
                onPressed: _handleSwitchUser, // Updated to call a wrapper
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
                  String username = await hfk.getCurrentUser(); // Stays, as it's UI related
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
              ElevatedButton(onPressed: () => _dhiveService.logout(), child: const Text('Logout')),
              ElevatedButton(onPressed: () => _dhiveService.singleVote('sagarkothari88', 'aihoa-based-login-with-hiveauth-and-sign-a-message-works-well-with-ios-app-now',1000), child: const Text('Vote')),
              ElevatedButton(
                onPressed: () => _dhiveService.deleteComment('permlinktodel'),
                child: const Text('Delete Comment'),
              ),
              ElevatedButton(onPressed: () => _dhiveService.reblog('sagarkothari', 'rblmtojs', true), child: const Text('Reblog')),
              ElevatedButton(
                onPressed: () => _dhiveService.reblog('sagarkothari', 'rblmtojs', false),
                child: const Text('Remove Reblog'),
              ),
              ElevatedButton(onPressed: () => _dhiveService.follow('sagarkothari', false), child: const Text('Follow')),
              ElevatedButton(
                onPressed: () => _dhiveService.follow('sagarkothari', true),
                child: const Text('Unfollow'),
              ),
              ElevatedButton(
                onPressed: () => _dhiveService.claimRewards(),
                child: const Text('Claim Rewards'),
              ),
              ElevatedButton(
                onPressed: () => _dhiveService.signMessage('Hello, hfk!', 'Posting'),
                child: const Text('Sign Message'),
              ),
              // --- End Basic User Actions ---

              // --- Account Authority Buttons ---
              ElevatedButton(
                onPressed: () => _dhiveService.addAccountAuthority(_usernameController.text, 'posting', 'threespeak', 1),
                child: const Text('Add Account Authority'),
              ),
              ElevatedButton(
                onPressed: () => _dhiveService.removeAccountAuthority(_usernameController.text, 'posting', 'threespeak'),
                child: const Text('Remove Account Authority'),
              ),
              // --- End Account Authority Buttons ---

              ElevatedButton(
                onPressed: _handleCommentWithOptions, // Updated to call a wrapper
                child: const Text('Comment with Options'),
              ),

              // --- Dhive Components Widget ---
              DhiveComponentsWidget(
                hfk: hfk, // hfk might still be needed for some direct calls or pass _dhiveService
                getChainPropertieshfk: () => _dhiveService.getChainProperties(),
                getDiscussionshfk: () => _dhiveService.getDiscussions('trending'), // Example parameters
                getAccountshfk: () => _dhiveService.getAccounts(['sagarkothari88']),
                getAccountPostshfk: () => _dhiveService.getAccountPosts('sagarkothari88', sort: 'comments'),
                getVotingPowerhfk: () => _dhiveService.getVotingPowerExtended('sagarkothari88'),
                getResourceCreditshfk: () => _dhiveService.getResourceCredits('sagarkothari88'),
                getFollowingsData: () => _dhiveService.getFollowingsData('sagarkothari88'),
                getFollowersData: () => _dhiveService.getFollowersData('sagarkothari88'),
                getWitnessVotesData: () => _dhiveService.getWitnessVotesData('sagarkothari88'),
                getProposalsExample: () => _dhiveService.getProposals(status: 'votable'),
                getAccountHistoryExample: () => _dhiveService.getAccountHistory('sagarkothari88'),
                checkThreespeakInAccountAuths: () => _threeSpeakService.checkThreespeakInAccountAuths(_usernameController.text),
                getCommentsListhfk: () => _dhiveService.getCommentsList('cositav','miwbidtw'),
                fetchCommunities: () => _handleFetchCommunities(loadMore: false),
                fetchMoreCommunities: (loadMore) => _handleFetchCommunities(loadMore: loadMore),
                communities: _communities,
                isLoadingCommunities: _isLoadingCommunities,
                hasMoreCommunities: _hasMoreCommunities,
                usernameController: _usernameController,
                showSnackBar: _showSnackBar,
                getWitnessesByVote: () => _dhiveService.getWitnessesByVote(limit: 10),
              ),
              // --- End Dhive Components Widget ---

              // QR Code Display Widget
              QrCodeDisplayWidget(
                qrString: qrString,
                timerDuration: timerDuration,
                onCancel: _clearQrDisplay, // Use the renamed callback
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
                onUserLogout: () => _dhiveService.logout(), // Updated to use DhiveService
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
