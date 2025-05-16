// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'package:aioha_flutter_core/models/login_model.dart';
import 'package:js/js.dart' show JS;
import 'package:js/js_util.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'aioha_flutter_core_platform_interface.dart';

@JS('loginWithKeychain')
external dynamic loginWithKeychainJS(String username, String proof);

@JS('loginWithHiveAuth')
external dynamic loginWithHiveAuthJS(String username, String proof);

@JS('loginWithPlaintextKey')
external dynamic loginWithPlaintextKeyJS(String username, String postingKey);

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
  Map<String, dynamic> jsonMetadata,
  Map<String, dynamic> options,
);

@JS('deleteComment')
external dynamic deleteCommentJS(String permlink);

@JS('reblog')
external dynamic reblogJS(String author, String permlink, bool reblogFlag);

@JS('follow')
external dynamic followJS(String author, bool followFlag);

@JS('removeOtherLogin')
external dynamic removeOtherLoginJS(String userId);

/// A web implementation of the AiohaFlutterCorePlatform of the AiohaFlutterCore plugin.
class AiohaFlutterCoreWeb extends AiohaFlutterCorePlatform {
  /// Constructs a AiohaFlutterCoreWeb
  static void registerWith(Registrar registrar) {
    AiohaFlutterCorePlatform.instance = AiohaFlutterCoreWeb();
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
  ) async {
    var promise = loginWithPlaintextKeyJS(username, postingKey);
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
    Map<String, dynamic> jsonMetadata,
    Map<String, dynamic> options,
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
}
