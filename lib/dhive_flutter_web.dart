// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:convert';

import 'package:aioha_flutter_core/models/account.dart';
import 'package:aioha_flutter_core/models/chain_properties.dart';
import 'package:aioha_flutter_core/models/discussion.dart';
import 'package:aioha_flutter_core/models/resource_credits.dart';
import 'package:aioha_flutter_core/models/voting_power.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'dhive_flutter_platform_interface.dart';

import 'dart:html' as html;
import 'dart:async';
import 'package:js/js.dart' show JS;
import 'package:js/js_util.dart';

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

@JS('getAccountPosts')
external dynamic getAccountPostsJS(
  String username,
  String by,
  int? limit,
  String? startAuthor,
  String? startPermlink,
  String? observer,
);

/// A web implementation of the DhiveFlutterPlatform of the DhiveFlutter plugin.
class DhiveFlutterWeb extends DhiveFlutterPlatform {
  /// Constructs a DhiveFlutterWeb
  DhiveFlutterWeb();

  static void registerWith(Registrar registrar) {
    DhiveFlutterPlatform.instance = DhiveFlutterWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
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
}
