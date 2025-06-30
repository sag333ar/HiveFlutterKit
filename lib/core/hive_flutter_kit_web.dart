// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter_kit/core/models/followers.dart';
import 'package:hive_flutter_kit/core/models/followings.dart';
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/core/models/witnessvote.dart';
import 'package:js/js.dart' show JS;
import 'package:js/js_util.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:hive_flutter_kit/core/models/account.dart';
import 'package:hive_flutter_kit/core/models/chain_properties.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/core/models/resource_credits.dart';
import 'package:hive_flutter_kit/core/models/voting_power.dart';
import 'package:hive_flutter_kit/core/models/community_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/communities_models/community_subscriber.dart';

import 'hive_flutter_kit_platform_interface.dart';

@JS('getChainProperties')
external dynamic getChainPropertiesJS();

@JS('getDiscussions')
external dynamic getDiscussionsJS(
  String by,
  int limit,
  String tag,
  String? startAuthor,
  String? startPermlink,
  String? observer,
);

@JS('getAccounts')
external dynamic getAccountsJS(List<String> usernames);

@JS('getVotingPowerData')
external dynamic getVotingPowerData(String username);

@JS('getResourceCreditsPercentage')
external dynamic getResourceCreditsPercentage(String username);

@JS('getFollowingsData')
external dynamic getFollowingsDataJS(
  String username,
  String? start,
  String? type,
  int? limit,
);

@JS('getFollowersData')
external dynamic getFollowersDataJS(
  String username,
  String? start,
  String? type,
  int? limit,
);

@JS('getWitnessVotesData')
external dynamic getWitnessVotesDataJS(String username);

@JS('getAccountPosts')
external dynamic getAccountPostsJS(
  String username,
  String by,
  int? limit,
  String? startAuthor,
  String? startPermlink,
  String? observer,
);

@JS('getListOfCommunities')
external dynamic getListOfCommunitiesJS(
  String? last,
  int limit,
  String? query,
  String? observer,
);

@JS('getCommentsList')
external Object getCommentsListJS(String author, String permlink);

@JS('getCommunitySubscribers')
external dynamic getCommunitySubscribersJS(
  String community,
  int limit,
  String? last,
);

@JS('getActiveVotes')
external dynamic getActiveVotesJS(String author, String permlink);

// -------------------------------------------------------------------------

@JS('loginWithKeychain')
external dynamic loginWithKeychainJS(String username, String proof);

@JS('loginWithHiveAuth')
external dynamic loginWithHiveAuthJS(String username, String proof);

@JS('loginWithPlaintextKey')
external dynamic loginWithPlaintextKeyJS(
  String username,
  String postingKey,
  String proof,
);

@JS('getQrString')
external dynamic getQrStringJS();

@JS('getCurrentUser')
external dynamic getCurrentUserJS();

@JS('logoutUser')
external dynamic logoutUserJS();

@JS('singleVote')
external dynamic singleVoteJS(String author, String permlink, int weight);

@JS('switchUser')
external dynamic switchUserJS(String userId);

@JS('getOtherLogins')
external dynamic getOtherLoginsJS();

@JS('signMessage')
external dynamic signMessageJS(String message, String username);

@JS('comment')
external dynamic commentJS(
  String parentAuthor,
  String parentPermlink,
  String permlink,
  String title,
  String body,
  Map<String, dynamic> jsonMetadata,
);
@JS('commentWithOptions')
external dynamic commentWithOptionsJS(
  String parentAuthor,
  String parentPermlink,
  String permlink,
  String title,
  String body,
  String jsonMetadata,
  String options,
);

@JS('deleteComment')
external dynamic deleteCommentJS(String permlink);

@JS('reblog')
external dynamic reblogJS(String author, String permlink, bool reblogFlag);

@JS('follow')
external dynamic followJS(String author, bool followFlag);

@JS('removeOtherLogin')
external dynamic removeOtherLoginJS(String userId);

@JS('addAccountAuthority')
external dynamic addAccountAuthorityJS(
  String account,
  String keyType,
  int weight,
);

@JS('removeAccountAuthority')
external dynamic removeAccountAuthorityJS(String account, String keyType);

@JS('signAndBroadcastTx')
external dynamic signAndBroadcastTxJS(
  dynamic operations, // pass as List<dynamic>
  String keyType,
);

@JS('transfer')
external dynamic transferJS(
  String recipient,
  double amount,
  String assetSymbol, // 'HIVE' or 'HBD'
  String? memo,
);

@JS('isHiveKeychainAvailable')
external dynamic isHiveKeychainAvailableJS();

/// A web implementation of the HiveFlutterKitPlatform of the HiveFlutterKit plugin.
class HiveFlutterKitWeb extends HiveFlutterKitPlatform {
  /// Constructs a HiveFlutterKitWeb
  static void registerWith(Registrar registrar) {
    HiveFlutterKitPlatform.instance = HiveFlutterKitWeb();
  }

  @override
  Future<LoginModel> loginWithKeychain(String username, String proof) async {
    var promise = loginWithKeychainJS(username, proof);
    var result = await promiseToFuture(promise);
    return LoginModel.fromJsonString(result);
  }

  @override
  Future<LoginModel> loginWithHiveAuth(String username, String proof) async {
    var promise = loginWithHiveAuthJS(username, proof);
    var result = await promiseToFuture(promise);
    return LoginModel.fromJsonString(result);
  }

  @override
  Future<LoginModel> loginWithPlaintextKey(
    String username,
    String postingKey,
    String proof,
  ) async {
    var promise = loginWithPlaintextKeyJS(username, postingKey, proof);
    var result = await promiseToFuture(promise);
    return LoginModel.fromJsonString(result);
  }

  @override
  Future<String> getQrString() async {
    var promise = getQrStringJS();
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> getCurrentUser() async {
    var promise = getCurrentUserJS();
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> logout() async {
    var promise = logoutUserJS();
    var contentData = await promiseToFuture(promise);
    return contentData.toString();
  }

  @override
  Future<String> singleVote(String author, String permlink, int weight) async {
    var promise = singleVoteJS(author, permlink, weight);
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> comment(
    String parentAuthor,
    String parentPermlink,
    String permlink,
    String title,
    String body,
    Map<String, dynamic> jsonMetadata,
  ) async {
    var promise = commentJS(
      parentAuthor,
      parentPermlink,
      permlink,
      title,
      body,
      jsonMetadata,
    );
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> commentWithOptions(
    String parentAuthor,
    String parentPermlink,
    String permlink,
    String title,
    String body,
    String jsonMetadata,
    String options,
  ) async {
    var promise = commentWithOptionsJS(
      parentAuthor,
      parentPermlink,
      permlink,
      title,
      body,
      jsonMetadata,
      options,
    );
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> deleteComment(String permlink) async {
    var promise = deleteCommentJS(permlink);
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> reblog(String author, String permlink, bool reblogFlag) async {
    var promise = reblogJS(author, permlink, reblogFlag);
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> follow(String author, bool followFlag) async {
    var promise = followJS(author, followFlag);
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<List<String>> getOtherLogins() async {
    var promise = getOtherLoginsJS();
    var contentData = await promiseToFuture(promise);
    return List<String>.from(contentData);
  }

  @override
  Future<String> signMessage(String message, String keyType) async {
    var promise = signMessageJS(message, keyType);
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<bool> switchUser(String userId) async {
    var promise = switchUserJS(userId);
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> removeOtherLogin(String userId) async {
    var promise = removeOtherLoginJS(userId);
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> addAccountAuthority(
    String account,
    String keyType,
    int weight,
  ) async {
    var promise = addAccountAuthorityJS(account, keyType, weight);
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> removeAccountAuthority(String account, String keyType) async {
    var promise = removeAccountAuthorityJS(account, keyType);
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<ChainProperties> getChainProperties() async {
    var promise = getChainPropertiesJS();
    var contentData = await promiseToFuture(promise);
    return ChainProperties.fromJsonString(contentData);
  }

  @override
  Future<List<Discussion>> getDiscussions(
    String by, {
    required int limit,
    String tag = '',
    String? startAuthor,
    String? startPermlink,
    String? observer,
  }) async {
    var promise = getDiscussionsJS(
      by,
      limit,
      tag,
      startAuthor,
      startPermlink,
      observer,
    );
    var jsonString = await promiseToFuture(promise);
    var contentData = jsonDecode(jsonString);
    return (contentData as List).map((e) => Discussion.fromJson(e)).toList();
  }

  @override
  Future<List<Account>> getAccounts(List<String> usernames) async {
    var promise = getAccountsJS(usernames);
    var contentData = await promiseToFuture(promise);
    return Account.listFromJsonString(contentData);
  }

  @override
  Future<VotingPower> getVotingPower(String username) async {
    try {
      var promise = getVotingPowerData(username);
      var contentData = await promiseToFuture(promise);

      if (contentData == null || contentData == 'error') {
        return VotingPower();
      }

      var votingPower = VotingPower.fromJsonString(contentData);
      return votingPower;
    } catch (e) {
      print("Error in getVotingPower: $e");
      return VotingPower();
    }
  }

  @override
  Future<ResourceCredits> getResourceCredits(String username) async {
    try {
      var promise = await getResourceCreditsPercentage(username);
      var contentData = await promiseToFuture(promise);
      if (contentData == 'error' || contentData == null) {
        print("Error fetching profile data or null value received.");
        return ResourceCredits();
      }
      return ResourceCredits(
        percentage: double.tryParse(contentData.toString()),
      );
    } catch (e) {
      print("Error in getResourceCredits: $e");
      return ResourceCredits();
    }
  }

  @override
  Future<List<Discussion>> getAccountPosts(
    String username,
    String by, {
    required int limit,
    String? startAuthor,
    String? startPermlink,
    String? observer,
  }) async {
    var promise = getAccountPostsJS(
      username,
      by,
      limit,
      startAuthor,
      startPermlink,
      observer,
    );
    var jsonString = await promiseToFuture(promise);
    var jsonMap = jsonDecode(jsonString); // Decode the JSON string
    if (jsonMap is List) {
      return jsonMap.map((json) => Discussion.fromJson(json)).toList();
    } else {
      throw Exception("Expected a list of posts, but got: $jsonMap");
    }
  }

  @override
  Future<bool> hasThreespeakInAccountAuths(String username) async {
    final accounts = await getAccounts([username]);
    if (accounts.isNotEmpty) {
      final accountAuths = accounts[0].posting?.accountAuths;
      if (accountAuths != null) {
        return accountAuths.any(
          (auth) => auth.isNotEmpty && auth[0] == 'threespeak',
        );
      }
    }
    return false;
  }

  @override
  Future<List<CommunityItem>> getListOfCommunities(
    String? query, {
    int limit = 20,
    String? last,
    String? observer,
  }) async {
    try {
      final promise = getListOfCommunitiesJS(last, limit, query, observer);
      final jsonString = await promiseToFuture(promise);

      final jsonList = jsonDecode(jsonString);
      if (jsonList is List) {
        return jsonList.map((item) => CommunityItem.fromJson(item)).toList();
      } else {
        throw Exception("Expected a list of communities, got: $jsonList");
      }
    } catch (e) {
      throw Exception("Error fetching communities via JS: $e");
    }
  }

  @override
  Future<List<Discussion>> getCommentsList(
    String author,
    String permlink,
  ) async {
    try {
      final promise = getCommentsListJS(author, permlink);
      final jsonString = await promiseToFuture(promise);
      final jsonMap = jsonDecode(jsonString);

      if (jsonMap is Map<String, dynamic>) {
        final comments = <Discussion>[];

        for (var entry in jsonMap.entries) {
          if (entry.value is Map<String, dynamic>) {
            final comment = Discussion.fromJson(entry.value);
            comments.add(comment);
          }
        }

        return comments;
      } else {
        throw Exception("Expected a map of comments, but got: $jsonMap");
      }
    } catch (e) {
      throw Exception("Error fetching comments via JS: $e");
    }
  }

  @override
  Future<dynamic> signAndBroadcastTx(
    dynamic operationRequest,
    String keyType,
  ) async {
    var promise = signAndBroadcastTxJS(jsonEncode(operationRequest), keyType);
    var result = await promiseToFuture(promise);
    return jsonDecode(result);
  }

  @override
  Future<String> transfer(
    String recipient,
    double amount,
    String assetSymbol,
    String? memo,
  ) async {
    var promise = transferJS(recipient, amount, assetSymbol, memo);
    var result = await promiseToFuture(promise);
    // Assuming the JS function returns a JSON string that might represent
    // success or an error object, similar to other methods.
    // For now, we'll return the raw string, but ideally, this should be
    // parsed into a structured Dart object or throw a Dart exception.
    return result as String;
  }

  @override
  Future<List<CommunitySubscriber>> getCommunitySubscribers(
    String community, {
    int limit = 100,
    String? last,
  }) async {
    var promise = getCommunitySubscribersJS(community, limit, last);
    var jsonString = await promiseToFuture(promise);
    return CommunitySubscriber.listFromJsonString(jsonString);
  }

  @override
  Future<List<ActiveVote>> getActiveVotes(
    String author,
    String permlink,
  ) async {
    var promise = getActiveVotesJS(author, permlink);
    var jsonString = await promiseToFuture(promise);
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => ActiveVote.fromJson(e)).toList();
  }

  @override
  Future<FollowingsData> getFollowingsData(
    String username, {
    String? start = '',
    String? type = 'blog',
    int? limit = 1000,
  }) async {
    try {
      final promise = getFollowingsDataJS(username, start, type, limit);
      final content = await promiseToFuture(promise);
      if (content == null) return FollowingsData.empty();

      return FollowingsData.fromJson(jsonDecode(content));
    } catch (e) {
      print("Error in getFollowingsData: $e");
      return FollowingsData.empty();
    }
  }

  @override
  Future<FollowersData> getFollowersData(
    String username, {
    String? start = '',
    String? type = 'blog',
    int? limit = 1000,
  }) async {
    try {
      final promise = getFollowersDataJS(username, start, type, limit);
      final content = await promiseToFuture(promise);
      if (content == null) return FollowersData.empty();

      return FollowersData.fromJson(jsonDecode(content));
    } catch (e) {
      print("Error in getFollowersData: $e");
      return FollowersData.empty();
    }
  }

  @override
  Future<WitnessVotesData> getWitnessVotesData(String username) async {
    try {
      final promise = getWitnessVotesDataJS(username);
      final content = await promiseToFuture(promise);
      if (content == null) return WitnessVotesData.empty();

      return WitnessVotesData.fromJson(jsonDecode(content));
    } catch (e) {
      print("Error in getWitnessVotesData: $e");
      return WitnessVotesData.empty();
    }
  }
  
  @override
  Future<bool> isHiveKeychainAvailable() async {
    var promise = isHiveKeychainAvailableJS();
    var result = await promiseToFuture(promise);
    return result == true;
  }
}
