import 'package:hive_flutter_kit/hive_flutter_kit.dart';
// import 'package:flutter/material.dart'; // Replaced by foundation for VoidCallback/ValueChanged if sufficient

// import 'dart:convert'; // Not currently used
import 'package:flutter/foundation.dart'; // For debugPrint, ValueChanged, VoidCallback
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart'; // Required for HiveFlutterKitPlatform
import 'package:hive_flutter_kit/core/models/community_model.dart'; // Required for CommunityItem


class DhiveService {
  final HiveFlutterKitPlatform hfk;
  final Function(String message) showSnackBar;
  final VoidCallback? startHiveAuthTimer; // Reverted name
  final VoidCallback? cancelHiveAuthTimer; // Reverted name


  DhiveService({
    required this.hfk,
    required this.showSnackBar,
    this.startHiveAuthTimer, // Reverted
    this.cancelHiveAuthTimer, // Reverted
  });

  Future<void> getVotingPower(String username) async {
    if (username.isEmpty) {
      showSnackBar('Username is required');
      return;
    }
    try {
      var result = await hfk.getVotingPower(username);
      debugPrint(
        "Voting Power: ${result.downvotePower}, ${result.upvotePower}",
      );
      // Optionally, return the result or show it via snackbar
      showSnackBar("Voting Power: Up - ${result.upvotePower}%, Down - ${result.downvotePower}%");
    } catch (e) {
      showSnackBar('Error getting voting power: $e');
    }
  }

  Future<void> logout() async {
    try {
      var userStatus = await hfk.getCurrentUser();
      userStatus = userStatus.replaceAll('"', '');

      if (userStatus.isEmpty ||
          userStatus.contains('No user is currently logged in')) {
        showSnackBar('No user is currently logged in');
        return;
      }
      await hfk.logout();
      showSnackBar('Successfully logged out');
    } catch (e) {
      showSnackBar('Error during logout: $e');
    }
  }

  Future<void> singleVote(String author, String permlink, int weight) async {
    try {
      startHiveAuthTimer?.call();
      final result = await hfk.singleVote(author, permlink, weight);
      showSnackBar('Vote Success: $result');
    } catch (e) {
      showSnackBar('Vote Error: $e');
    } finally {
      cancelHiveAuthTimer?.call();
    }
  }

  Future<void> comment(String parentAuthor, String parentPermlink, String permlink, String title, String body, Map<String, dynamic> jsonMetadata) async {
    try {
      final result = await hfk.comment(parentAuthor, parentPermlink, permlink, title, body, jsonMetadata);
      showSnackBar('Comment Success: $result');
    } catch (e) {
      showSnackBar('Comment Error: $e');
    }
  }

  Future<void> commentWithOptions({
    required String parentAuthor,
    required String parentPermlink,
    required String permlink,
    required String title,
    required String body,
    required String jsonMetadataStr, // Already a JSON string
    required String optionsStr, // Already a JSON string
  }) async {
    try {
      final result = await hfk.commentWithOptions(
        parentAuthor,
        parentPermlink,
        permlink,
        title,
        body,
        jsonMetadataStr,
        optionsStr,
      );
      showSnackBar('CommentWithOptions Success: $result');
    } catch (e) {
      showSnackBar('CommentWithOptions Error: $e');
    }
  }

  Future<void> deleteComment(String permlink) async {
    try {
      startHiveAuthTimer?.call();
      final result = await hfk.deleteComment(permlink);
      showSnackBar('Delete Comment Success: $result');
    } catch (e) {
      showSnackBar('Delete Comment Error: $e');
    } finally {
      cancelHiveAuthTimer?.call();
    }
  }

  Future<void> reblog(String author, String permlink, bool isReblog) async {
    try {
      final result = await hfk.reblog(author, permlink, isReblog);
      showSnackBar(isReblog ? 'Reblog Success: $result' : 'Remove Reblog Success: $result');
    } catch (e) {
      showSnackBar(isReblog ? 'Reblog Error: $e' : 'Remove Reblog Error: $e');
    }
  }

  Future<void> follow(String username, bool isUnfollow) async {
    try {
      final result = await hfk.follow(username, isUnfollow);
      debugPrint(isUnfollow ? 'Unfollow result: $result' : 'Follow result: $result');
      showSnackBar(isUnfollow ? 'Unfollow Success: $result' : 'Follow Success: $result');
    } catch (e) {
      debugPrint(isUnfollow ? 'Unfollow failed: $e' : 'Follow failed: $e');
      showSnackBar(isUnfollow ? 'Unfollow Error: $e' : 'Follow Error: $e');
    }
  }

  Future<void> switchUser(String username, ValueChanged<String> onSwitchSuccess, ValueChanged<String> onRemoveSuccess) async {
    try {
      final otherLogins = await hfk.getOtherLogins();
      debugPrint('Other logged-in users: $otherLogins');

      if (otherLogins.isEmpty) {
        showSnackBar('No other logged-in users available');
        return;
      }

      // This part requires context to show a dialog.
      // For now, let's assume the UI part (dialog) is handled in the widget,
      // and this service method just provides the data or performs the action.
      // Or, the calling widget can pass a function to show the dialog.
      // For simplicity here, I'll just log and show a snackbar.
      // A more robust solution would involve passing a dialog display function.

      // Example: Switching to the first available user for demonstration
      // final selectedUser = otherLogins.first;
      // final result = await hfk.switchUser(selectedUser);
      // debugPrint('Switch user result: $result');
      // onSwitchSuccess(selectedUser); // Call callback on success

      // The dialog logic from home.dart needs to be invoked by the calling widget.
      // This service method can be split or adapted.
      // For now, I'll keep the core logic of fetching users.
      // The actual switching/removing will be triggered by UI actions.

    } catch (e) {
      debugPrint('Switch user failed: $e');
      showSnackBar('Error managing users: $e');
    }
  }

  Future<List<String>> getOtherLogins() async {
    try {
      return await hfk.getOtherLogins();
    } catch (e) {
      showSnackBar('Failed to get other logins: $e');
      return [];
    }
  }

  Future<void> performSwitchUser(String username) async {
    try {
      final result = await hfk.switchUser(username);
      showSnackBar('Switched to user: $username. Result: $result');
    } catch (e) {
      showSnackBar('Failed to switch to user $username: $e');
    }
  }

  Future<void> performRemoveOtherLogin(String username) async {
    try {
      final result = await hfk.removeOtherLogin(username);
      showSnackBar('Removed user: $username. Result: $result');
    } catch (e) {
      showSnackBar('Failed to remove user $username: $e');
    }
  }


  Future<void> claimRewards() async {
    try {
      final result = await hfk.claimRewards();
      debugPrint('Claim Rewards result: $result');
      showSnackBar('Claim Rewards Success: $result');
    } catch (e) {
      debugPrint('Claim Rewards failed: $e');
      showSnackBar('Claim Rewards Error: $e');
    }
  }

  Future<void> signMessage(String message, String keyTypeString) async {
    try {
      // Assuming KeyType is an enum or similar. The string needs to be mapped.
      // For now, using the string directly if the native side handles it.
      // If KeyType is an enum like `enum KeyType { POSTING, ACTIVE, MEMO }`
      // You might need: `KeyType keyType = KeyType.values.firstWhere((e) => e.toString().split('.').last.toLowerCase() == keyTypeString.toLowerCase());`
      // For simplicity, assuming the platform interface takes a string.
      // The original code uses 'Posting', so it's likely a string.
      startHiveAuthTimer?.call();
      final result = await hfk.signMessage(message, keyTypeString);
      debugPrint('Sign Message result: $result');
      showSnackBar('Sign Message Success: $result');
    } catch (e) {
      debugPrint('Sign Message failed: $e');
      showSnackBar('Sign Message Error: $e');
    } finally {
      cancelHiveAuthTimer?.call();
    }
  }

  Future<void> addAccountAuthority(String username, String role, String authAccount, int weight) async {
    if (username.isEmpty) {
      showSnackBar('Username is required for account authority changes');
      return;
    }
    try {
      final result = await hfk.addAccountAuthority(authAccount, role, weight);
      showSnackBar('Add Account Authority Success: $result');
    } catch (e) {
      showSnackBar('Add Account Authority Error: $e');
    }
  }

  Future<void> removeAccountAuthority(String username, String role, String authAccount) async {
    if (username.isEmpty) {
      showSnackBar('Username is required for account authority changes');
      return;
    }
    try {
      final result = await hfk.removeAccountAuthority(authAccount, role);
      showSnackBar('Remove Account Authority Success: $result');
    } catch (e) {
      showSnackBar('Remove Account Authority Error: $e');
    }
  }

  Future<void> getChainProperties() async {
    try {
      var result = await hfk.getChainProperties();
      debugPrint("HFK Chain Properties: $result");
      showSnackBar('Chain Properties: $result');
    } catch (e) {
      debugPrint('HFK getChainProperties error: $e');
      showSnackBar('Chain Properties Error: $e');
    }
  }

  Future<List<Discussion>> getDiscussions(String by, {
    int limit = 20,
    String? tag,
    String? startAuthor,
    String? startPermlink,
    String? observer,
  }) async {
    try {
      final result = await hfk.getDiscussions(
        by,
        limit: limit,
        tag: tag ?? '',
        startAuthor: startAuthor,
        startPermlink: startPermlink,
        observer: observer ?? '',
      );
      for (var discussion in result) {
        final metadata = discussion.jsonMetadata;
        debugPrint('--- ${discussion.title} ---');
        // ... (other debug prints)
      }
      showSnackBar('Fetched discussions (see debug output)');
      return result;
    } catch (e) {
      debugPrint('HFK getDiscussions error: $e');
      showSnackBar('Get Discussions Error: $e');
      return [];
    }
  }

  Future<List<Account>> getAccounts(List<String> usernames) async {
    try {
      var result = await hfk.getAccounts(usernames);
      for (var account in result) {
        debugPrint("Account: ${account.name}, Posting Auths: ${account.posting?.accountAuths}");
      }
      showSnackBar('Fetched accounts (see debug output)');
      return result;
    } catch (e) {
      debugPrint('HFK getAccounts error: $e');
      showSnackBar('Get Accounts Error: $e');
      return [];
    }
  }

  Future<List<Post>> getAccountPosts(
    String username, {
    int limit = 20,
    String sort = 'posts', // Default to 'posts', can be 'comments', 'blog', etc.
    String? observer,
    String? startAuthor,
    String? startPermlink,
  }) async {
    try {
      var result = await hfk.getAccountPosts(
        username,
        limit: limit,
        sort,
        observer: observer,
        startAuthor: startAuthor,
        startPermlink: startPermlink,
      );
      if (result.isEmpty) {
        debugPrint('No posts found for $username with sort $sort.');
      } else {
        for (var post in result) {
          // debugPrint('--- Post Debug Start ---');
          // ... (detailed debug prints for each post)
          // debugPrint('--- Post Debug End ---\n');
        }
      }
      showSnackBar('Fetched account posts for $username (see debug output)');
      return result;
    } catch (e) {
      debugPrint('HFK getAccountPosts for $username error: $e');
      showSnackBar('Get AccountPosts Error: $e');
      return [];
    }
  }

  Future<VotingPower?> getVotingPowerExtended(String username) async {
    try {
      var result = await hfk.getVotingPower(username);
      debugPrint("Voting Power: ${result.downvotePower}, ${result.upvotePower}");
      showSnackBar('Voting Power: ${result.downvotePower}, ${result.upvotePower}');
      return result;
    } catch (e) {
      debugPrint('HFK getVotingPower error: $e');
      showSnackBar('Get Voting Power Error: $e');
      return null;
    }
  }

  Future<ResourceCredits?> getResourceCredits(String username) async {
    try {
      var result = await hfk.getResourceCredits(username);
      debugPrint("Resources Credits Percentage: ${result.percentage}");
      showSnackBar('Resources Credits Percentage: ${result.percentage}');
      return result;
    } catch (e) {
      debugPrint('HFK getResourceCredits error: $e');
      showSnackBar('Get Resource Credits Error: $e');
      return null;
    }
  }

  Future<FollowingsData?> getFollowingsData(String username, {String start = '', String type = 'blog', int limit = 100}) async {
    try {
      var result = await hfk.getFollowingsData(username, start: start, type: type, limit: limit);
      debugPrint("Followings Count for $username: ${result.count}");
      // for (var user in result.followings ?? []) {
      //   debugPrint("Following: ${user['following']}");
      // }
      showSnackBar('Fetched ${result.count} followings for $username');
      return result;
    } catch (e) {
      debugPrint('getFollowingsData for $username error: $e');
      showSnackBar('Failed to get followings for $username');
      return null;
    }
  }

  Future<FollowersData?> getFollowersData(String username, {String start = '', String type = 'blog', int limit = 100}) async {
    try {
      var result = await hfk.getFollowersData(username, start: start, type: type, limit: limit);
      debugPrint("Followers Count for $username: ${result.count}");
      // for (var user in result.followers ?? []) {
      //   debugPrint("Follower: ${user['follower']}");
      // }
      showSnackBar('Fetched ${result.count} followers for $username');
      return result;
    } catch (e) {
      debugPrint('getFollowersData for $username error: $e');
      showSnackBar('Failed to get followers for $username');
      return null;
    }
  }

  Future<WitnessVotesData?> getWitnessVotesData(String username) async {
    try {
      var result = await hfk.getWitnessVotesData(username);
      // for (var witness in result.witnessVotes ?? []) {
      //   debugPrint("Voted for by $username: $witness");
      // }
      debugPrint("Witnesses voted for by $username: ${result.witnessesVotedFor ?? 0}");
      showSnackBar('Witnesses voted for by $username: ${result.witnessesVotedFor ?? 0}');
      return result;
    } catch (e) {
      debugPrint('getWitnessVotesData for $username error: $e');
      showSnackBar('Failed to get witness votes for $username');
      return null;
    }
  }

  Future<List<AccountHistory>> getAccountHistory(String account, {int index = -1, int limit = 100, String? start, String? stop}) async {
    try {
      final result = await hfk.getAccountHistory(account, index: index, limit: limit, start: start, stop: stop);
      if (result.isEmpty) {
        debugPrint('No account history found for $account.');
      } else {
        // for (var op in result) {
        //   debugPrint('--- History Op Start for $account ---');
        //   // ... (detailed debug prints)
        //   debugPrint('--- History Op End ---\n');
        // }
      }
      showSnackBar('Fetched account history for $account (see debug output)');
      return result;
    } catch (e) {
      debugPrint('Error in getAccountHistory for $account: $e');
      showSnackBar('Get Account History Error for $account: $e');
      return [];
    }
  }

  Future<List<Proposal>> getProposals({List<dynamic> start = const [], int limit = 100, String order = 'by_total_votes', String orderDirection = 'descending', String status = 'votable'}) async {
    try {
      final result = await hfk.getProposals(start: start, limit: limit, order: order, orderDirection: orderDirection, status: status);
      debugPrint('Fetched ${result.length} proposals with status $status');
      // if (result.isEmpty) {
      //   debugPrint('No proposals found with status $status.');
      // } else {
      //   for (var proposal in result) {
      //     // debugPrint('--- Proposal Start ---');
      //     // ... (detailed debug prints)
      //     // debugPrint('--- Proposal End ---\n');
      //   }
      // }
      showSnackBar('Fetched proposals (see debug output)');
      return result;
    } catch (e) {
      debugPrint('Error in getProposals: $e');
      showSnackBar('Get Proposals Error: $e');
      return [];
    }
  }

  Future<List<CommunityItem>> fetchCommunities(String? query, int limit, String? last, String? observer) async {
    try {
      final result = await hfk.getListOfCommunities(
        query,
        limit: limit,
        last: last,
        observer: observer,
      );
      showSnackBar('Fetched ${result.length} communities');
      return result;
    } catch (e) {
      showSnackBar('Error fetching communities: $e');
      return [];
    }
  }

  Future<List<CommentDetails>> getCommentsList(String author, String permlink) async {
    try {
      final comments = await hfk.getCommentsList(author, permlink);
      if (comments.isEmpty) {
        debugPrint('No comments found for $author/$permlink.');
      } else {
        // debugPrint('--- Comments Start for $author/$permlink ---');
        // for (var comment in comments) {
        //   // debugPrint('Author: ${comment.author}');
        //   // ... (other debug prints)
        // }
        // debugPrint('--- Comments End ---');
      }
      showSnackBar('Fetched ${comments.length} comments for $author/$permlink');
      return comments;
    } catch (e) {
      debugPrint('HFK getCommentsList error for $author/$permlink: $e');
      showSnackBar('Get Comments Error: $e');
      return [];
    }
  }

  Future<List<Witness>> getWitnessesByVote({int limit = 50}) async {
    try {
      final result = await hfk.getWitnessesByVote(limit: limit);
      debugPrint('Witnesses by vote: ${result.map((w) => w.name).join(', ')}');
      showSnackBar('Fetched ${result.length} witnesses by vote');
      return result;
    } catch (e) {
      debugPrint('Error fetching witnesses by vote: $e');
      showSnackBar('Error fetching witnesses: $e');
      return [];
    }
  }
}
