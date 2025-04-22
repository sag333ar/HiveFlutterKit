// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:async';
import 'package:js/js.dart' show JS;
import 'package:js/js_util.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'aioha_flutter_core_platform_interface.dart';

@JS('loginWithKeychain')
external dynamic loginWithKeychainJS(String username);

@JS('loginWithHiveAuth')
external dynamic loginWithHiveAuthJS(String username);

@JS('getQrString')
external dynamic getQrStringJS();

@JS('getCurrentUser')
external dynamic getCurrentUserJS();

@JS('logoutUser')
external dynamic logoutUserJS();

@JS('singleVote')
external dynamic singleVoteJS(String author, String permlink, int weight);

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

/// A web implementation of the AiohaFlutterCorePlatform of the AiohaFlutterCore plugin.
class AiohaFlutterCoreWeb extends AiohaFlutterCorePlatform {
  /// Constructs a AiohaFlutterCoreWeb
  AiohaFlutterCoreWeb() {
    showWebViewContent();
  }

  static void registerWith(Registrar registrar) {
    AiohaFlutterCorePlatform.instance = AiohaFlutterCoreWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }

  void showWebViewContent() {
    if (html.document.getElementById('aioha-iframe') != null) return;
    html.IFrameElement iframe =
        html.IFrameElement()
          ..src = 'assets/packages/aioha_flutter_core/assets/web/index.html'
          ..id = 'aioha-iframe'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
    html.document.body?.append(iframe);
  }

  @override
  Future<String> loginWithKeychain(String username) async {
    var promise = loginWithKeychainJS(username);
    var contentData = await promiseToFuture(promise);
    return contentData;
  }

  @override
  Future<String> loginWithHiveAuth(String username) async {
    var promise = loginWithHiveAuthJS(username);
    var contentData = await promiseToFuture(promise);
    return contentData;
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
    return contentData;
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
}
