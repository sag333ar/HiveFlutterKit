import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter_kit/core/models/account_history.dart';
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter_kit/core/models/pending_reward.dart';

import 'hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/account.dart';
import 'package:hive_flutter_kit/core/models/chain_properties.dart';
import 'package:hive_flutter_kit/core/models/discussion.dart';
import 'package:hive_flutter_kit/core/models/resource_credits.dart';
import 'package:hive_flutter_kit/core/models/voting_power.dart';
import 'package:hive_flutter_kit/core/models/community_model.dart';
import 'package:hive_flutter_kit/core/three_speak_core/models/communities_models/community_subscriber.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// An implementation of [HiveFlutterKitPlatform] that uses method channels.
class MethodChannelHiveFlutterKit extends HiveFlutterKitPlatform {
  late HeadlessInAppWebView headlessWebView;
  late Future<void> _webViewInitFuture;
  var isWebViewRunning = false;

  MethodChannelHiveFlutterKit() {
    _webViewInitFuture = initHeadlessWebView();
  }

  Future<void> initHeadlessWebView() async {
    String htmlContent = await _loadHTMLFromAssets();

    headlessWebView = HeadlessInAppWebView(
      initialData: InAppWebViewInitialData(
        data: htmlContent,
        encoding: "utf-8",
        mimeType: "text/html",
        historyUrl: WebUri.uri(Uri.parse("http://localhost")),
        baseUrl: WebUri.uri(Uri.parse("http://localhost")),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        cacheEnabled: true,
        allowsInlineMediaPlayback: true,
        javaScriptCanOpenWindowsAutomatically: true,
        transparentBackground: true,
      ),
      onWebViewCreated: (controller) {
        print("WebView created");
      },
      onLoadStop: (controller, url) {
        print("WebView load finished: $url");
        isWebViewRunning = true;
      },
    );

    await headlessWebView.run();
  }

  Future<String> _loadHTMLFromAssets() async {
    String aiohajs = await rootBundle.loadString(
      "packages/hive_flutter_kit/web/hiveflutterkit.js",
    );
    String longHtml = """
<html>
<head><title>AIOHA HTML</title></head>
<body>
  <script>
  $aiohajs
  </script>
  </body>
  </html>
   """;

    return longHtml;
  }

  @override
  Future<LoginModel> loginWithKeychain(String username, String proof) async {
    throw UnimplementedError(
      'Hive Keychain based login not available for mobile-apps',
    );
  }

  @override
  Future<String> getQrString() async {
    await _webViewInitFuture; // 👈 Ensure initialized before use

    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onGetQrStringResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        var string = await getQrString();
        window.flutter_inappwebview.callHandler('onGetQrStringResult', string);
      })()
    """,
    );
    return completer.future;
  }

  @override
  Future<LoginModel> loginWithHiveAuth(String username, String proof) async {
    await _webViewInitFuture; // 👈 Ensure initialized before use

    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onHiveAuthResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    var source = """
    (async () => {
      try {
        const res = await loginWithHiveAuth('$username', '$proof');
        window.flutter_inappwebview.callHandler('onHiveAuthResult', res ?? 'null');
      } catch (e) {
        window.flutter_inappwebview.callHandler('onHiveAuthResult', 'Error: ' + e.toString());
      }
    })()
  """;
    await headlessWebView.webViewController?.evaluateJavascript(source: source);
    final result = await completer.future;
    return LoginModel.fromJsonString(result);
  }

  @override
  Future<LoginModel> loginWithPlaintextKey(
    String username,
    String postingKey,
    String proof,
  ) async {
    final completer = Completer<LoginModel>();

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onLoginWithPlaintextKeyResult',
      callback: (args) {
        if (!completer.isCompleted) {
          try {
            final resultJson = args[0];
            final result = LoginModel.fromJson(jsonDecode(resultJson));
            completer.complete(result);
          } catch (e) {
            completer.completeError("Parsing error: $e");
          }
        }
      },
    );

    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
    (async () => {
      try {
        const result = await loginWithPlaintextKey("$username", "$postingKey", "$proof");
        window.flutter_inappwebview.callHandler('onLoginWithPlaintextKeyResult', result);
      } catch (err) {
        window.flutter_inappwebview.callHandler('onLoginWithPlaintextKeyResult', JSON.stringify({ error: err.message }));
      }
    })();
    """,
    );
    return completer.future;
  }

  @override
  Future<String> singleVote(String author, String permlink, int weight) async {
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onSingleVoteResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await singleVote('$author', '$permlink', $weight);
          window.flutter_inappwebview.callHandler('onSingleVoteResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onSingleVoteResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<String> getCurrentUser() async {
    final completer = Completer<String>();
    // Success handler
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onGetCurrentUserResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );

    // Error handler
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onGetCurrentUserError',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.completeError(
            args.isNotEmpty ? args[0].toString() : 'Unknown error',
          );
        }
      },
    );

    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async() => {
        try {
          const res = await getCurrentUser();
          window.flutter_inappwebview.callHandler('onGetCurrentUserResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onGetCurrentUserError', 'Error: ' + e.toString());
        }
      })()
    """,
    );

    try {
      final result = await completer.future;
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> logout() async {
    final controller = headlessWebView.webViewController;
    if (controller == null) {
      return Future.value('WebView controller is null');
    }
    final completer = Completer<String>();
    controller.addJavaScriptHandler(
      handlerName: 'onLogoutResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(
            args.isNotEmpty ? args[0].toString() : 'Unknown logout result',
          );
        }
      },
    );
    await controller.evaluateJavascript(
      source: """
    (async () => {
      try {
        const res = await logoutUser();
        window.flutter_inappwebview.callHandler('onLogoutResult', res ?? 'null');
      } catch (e) {
        window.flutter_inappwebview.callHandler('onLogoutResult', 'Error: ' + e.toString());
      }
    })()
    """,
    );
    return completer.future;
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
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onCommentResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await comment('$parentAuthor', '$parentPermlink', '$permlink', '$title', '$body', ${jsonMetadata.toString()});
          window.flutter_inappwebview.callHandler('onCommentResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onCommentResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
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
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onCommentWithOptionsResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await comment('$parentAuthor', '$parentPermlink', '$permlink', '$title', '$body', ${jsonMetadata.toString()}, ${options.toString()});
          window.flutter_inappwebview.callHandler('onCommentWithOptionsResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onCommentWithOptionsResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<String> deleteComment(String permlink) async {
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onDeleteCommentResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await deleteComment('$permlink');
          window.flutter_inappwebview.callHandler('onDeleteCommentResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onDeleteCommentResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<String> reblog(String author, String permlink, bool reblogFlag) async {
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onReblogResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await reblog('$author', '$permlink', $reblogFlag);
          window.flutter_inappwebview.callHandler('onReblogResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onReblogResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<String> follow(String author, bool followFlag) async {
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onFollowResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await follow('$author', $followFlag);
          window.flutter_inappwebview.callHandler('onFollowResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onFollowResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<String> claimRewards() async {
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onClaimRewardsResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await claimRewards();
          window.flutter_inappwebview.callHandler('onClaimRewardsResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onClaimRewardsResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<String> signMessage(String message, String keyType) async {
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onSignMessageResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await signMessage('$message', '$keyType');
          window.flutter_inappwebview.callHandler('onSignMessageResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onSignMessageResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<List<String>> getOtherLogins() async {
    final completer = Completer<List<String>>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onGetOtherLoginsResult',
      callback: (args) {
        print("Other logins result from JS: $args");
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? List<String>.from(args[0]) : []);
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const logins = await getOtherLogins();
          window.flutter_inappwebview.callHandler('onGetOtherLoginsResult', logins);
        } catch (e) {
          window.flutter_inappwebview.callHandler('onGetOtherLoginsResult', []);
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<bool> switchUser(String userId) async {
    final completer = Completer<bool>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onSwitchUserResult',
      callback: (args) {
        print("Switch user result from JS: $args");
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty && args[0] == true);
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const result = switchUser('$userId');
          window.flutter_inappwebview.callHandler('onSwitchUserResult', result);
        } catch (e) {
          window.flutter_inappwebview.callHandler('onSwitchUserResult', false);
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<String> removeOtherLogin(String userId) async {
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onRemoveOtherLoginResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await removeOtherLogin('$userId');
          window.flutter_inappwebview.callHandler('onRemoveOtherLoginResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onRemoveOtherLoginResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<String> addAccountAuthority(
    String account,
    String keyType,
    int weight,
  ) async {
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onAddAccountAuthorityResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await addAccountAuthority('$account', '$keyType', $weight);
          window.flutter_inappwebview.callHandler('onAddAccountAuthorityResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onAddAccountAuthorityResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<String> removeAccountAuthority(String account, String keyType) async {
    final completer = Completer<String>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onRemoveAccountAuthorityResult',
      callback: (args) {
        if (!completer.isCompleted) {
          completer.complete(args.isNotEmpty ? args[0].toString() : 'null');
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        try {
          const res = await removeAccountAuthority('$account', '$keyType');
          window.flutter_inappwebview.callHandler('onRemoveAccountAuthorityResult', res ?? 'null');
        } catch (e) {
          window.flutter_inappwebview.callHandler('onRemoveAccountAuthorityResult', 'Error: ' + e.toString());
        }
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<ChainProperties> getChainProperties() async {
    final completer = Completer<ChainProperties>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'getChainPropertiesResult',
      callback: (args) {
        if (!completer.isCompleted) {
          var contentData = args.isNotEmpty ? args[0].toString() : 'null';
          if (contentData != 'null') {
            var chainProperties = ChainProperties.fromJsonString(contentData);
            completer.complete(chainProperties);
          } else {
            completer.completeError('Failed to get chain properties');
          }
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        var string = await getChainProperties();
        window.flutter_inappwebview.callHandler('getChainPropertiesResult', string);
      })()
      """,
    );
    return completer.future;
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
    final completer = Completer<List<Discussion>>();

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'getDiscussionsResult',
      callback: (args) {
        if (!completer.isCompleted) {
          try {
            final contentData = args.isNotEmpty ? jsonDecode(args[0]) : [];
            final discussions =
                (contentData as List)
                    .map((e) => Discussion.fromJson(e))
                    .toList();
            completer.complete(discussions);
          } catch (e) {
            completer.completeError('Failed to parse discussions: $e');
          }
        }
      },
    );

    try {
      final source = """
    (async () => {
      var discussions = await getDiscussions(
        ${jsonEncode(by)},
        $limit,
        ${jsonEncode(tag)},
        ${jsonEncode(startAuthor)},
        ${jsonEncode(startPermlink)},
        ${jsonEncode(observer)},
      );
      window.flutter_inappwebview.callHandler('getDiscussionsResult', JSON.stringify(discussions));
    })()
    """;

      await headlessWebView.webViewController?.evaluateJavascript(
        source: source,
      );
    } catch (e) {
      completer.completeError('JavaScript execution failed: $e');
    }

    return completer.future;
  }

  @override
  Future<List<Account>> getAccounts(List<String> usernames) async {
    final completer = Completer<List<Account>>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'getAccountsResult',
      callback: (args) {
        if (!completer.isCompleted) {
          var contentData = args.isNotEmpty ? args[0].toString() : 'null';
          if (contentData != 'null') {
            var accounts = Account.listFromJsonString(contentData);
            completer.complete(accounts);
          } else {
            completer.completeError('Failed to get accounts');
          }
        }
      },
    );

    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
    (async () => {
      var string = await getAccounts([${usernames.map((u) => '"$u"').join(',')}]);
      window.flutter_inappwebview.callHandler('getAccountsResult', string);
    })()
    """,
    );

    return completer.future;
  }

  @override
  Future<VotingPower> getVotingPower(String username) async {
    final completer = Completer<VotingPower>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'getVotingPowerResult',
      callback: (args) {
        if (!completer.isCompleted) {
          var contentData = args.isNotEmpty ? args[0].toString() : 'null';
          if (contentData != 'null') {
            var votingPower = VotingPower.fromJsonString(contentData);
            print("Voting Power Data: $votingPower"); // Debugging log
            completer.complete(votingPower);
          } else {
            completer.completeError('Failed to get voting power');
          }
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        var string = await getVotingPowerData("$username");
        window.flutter_inappwebview.callHandler('getVotingPowerResult', string);
      })()
      """,
    );
    return completer.future;
  }

  @override
  Future<ResourceCredits> getResourceCredits(String username) async {
    final completer = Completer<ResourceCredits>();
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'getResourceCreditsResult',
      callback: (args) {
        if (!completer.isCompleted) {
          var contentData = args.isNotEmpty ? args[0] : null;

          if (contentData != null) {
            var resourceCredits = ResourceCredits(
              percentage: double.tryParse(contentData.toString()),
            );
            completer.complete(resourceCredits);
          } else {
            completer.completeError('Failed to get resource credits');
          }
        }
      },
    );
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        var value = await getResourceCreditsPercentage("$username");
        window.flutter_inappwebview.callHandler('getResourceCreditsResult', value);
      })()
      """,
    );
    return completer.future;
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
    final completer = Completer<List<Discussion>>();

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'getAccountPostsResult',
      callback: (args) {
        if (!completer.isCompleted) {
          var contentData = args.isNotEmpty ? args[0].toString() : null;

          if (contentData != null &&
              contentData != 'null' &&
              contentData.isNotEmpty) {
            try {
              var posts = Discussion.fromJsonStringList(contentData);
              completer.complete(posts);
            } catch (e) {
              completer.completeError('Failed to parse posts: $e');
            }
          } else {
            completer.completeError(
              'Failed to get account posts or empty response',
            );
          }
        }
      },
    );

    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
    (async () => {
      var string = await getAccountPosts(
        "${jsonDecode(username)}",
        ${jsonEncode(by)},
        $limit,
        ${jsonEncode(startAuthor)},
        ${jsonEncode(startPermlink)},
        ${jsonEncode(observer)},
      );
      window.flutter_inappwebview.callHandler('getAccountPostsResult', string);
    })()
    """,
    );

    return completer.future;
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
    final completer = Completer<List<CommunityItem>>();

    // Setup JS handler
    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'getListOfCommunitiesResult',
      callback: (args) {
        if (!completer.isCompleted) {
          var contentData = args.isNotEmpty ? args[0].toString() : null;

          if (contentData != null &&
              contentData != 'null' &&
              contentData.isNotEmpty) {
            try {
              final jsonList = jsonDecode(contentData);
              final communities =
                  (jsonList as List)
                      .map((item) => CommunityItem.fromJson(item))
                      .toList();
              completer.complete(communities);
            } catch (e) {
              completer.completeError('Failed to parse communities: $e');
            }
          } else {
            completer.completeError('Empty or null JS result for communities');
          }
        }
      },
    );

    // Call the JS function via WebView
    await headlessWebView.webViewController?.evaluateJavascript(
      source: """
      (async () => {
        const result = await getListOfCommunities(
          ${jsonEncode(last)},
          $limit,
          ${jsonEncode(observer)},
        );
        window.flutter_inappwebview.callHandler('getListOfCommunitiesResult', result);
      })()
    """,
    );

    return completer.future;
  }

  @override
  Future<List<Discussion>> getCommentsList(
    String author,
    String permlink,
  ) async {
    await _webViewInitFuture;

    final completer = Completer<List<Discussion>>();

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'getCommentsListResult',
      callback: (args) {
        if (!completer.isCompleted) {
          final contentData = args.isNotEmpty ? args[0].toString() : null;

          if (contentData != null &&
              contentData != 'null' &&
              contentData.isNotEmpty) {
            try {
              final Map<String, dynamic> parsedMap = jsonDecode(contentData);

              // Patch: Convert all int to double for known double fields
              Map<String, dynamic> fixNumericFields(Map<String, dynamic> map) {
                final fieldsToDouble = [
                  'payout',
                  'author_reputation',
                  'curator_payout_value',
                  'pending_payout_value',
                  'author_payout_value',
                  'max_accepted_payout',
                  // add more fields as needed
                ];
                for (final key in fieldsToDouble) {
                  if (map.containsKey(key) && map[key] is int) {
                    map[key] = (map[key] as int).toDouble();
                  }
                }
                return map;
              }

              final comments =
                  parsedMap.values
                      .map(
                        (e) => Discussion.fromJson(
                          fixNumericFields(Map<String, dynamic>.from(e)),
                        ),
                      )
                      .toList();
              completer.complete(comments);
            } catch (e) {
              completer.completeError('Failed to parse comments: $e');
            }
          } else {
            completer.completeError('Failed to get comments or empty response');
          }
        }
      },
    );

    try {
      await headlessWebView.webViewController?.evaluateJavascript(
        source: """
      (async () => {
        try {
          var string = await getCommentsList(
            ${jsonEncode(author)},
            ${jsonEncode(permlink)}
          );
          window.flutter_inappwebview.callHandler('getCommentsListResult', string);
        } catch (e) {
          window.flutter_inappwebview.callHandler('getCommentsListResult', null);
        }
      })()
      """,
      );
    } catch (e) {
      completer.completeError('JavaScript execution failed: $e');
    }

    return completer.future;
  }

  @override
  Future<dynamic> signAndBroadcastTx(
    dynamic operationRequest,
    String keyType,
  ) async {
    final completer = Completer<dynamic>();

    // Remove previous handler if exists
    headlessWebView.webViewController?.removeJavaScriptHandler(
      handlerName: 'onSignAndBroadcastTxResult',
    );

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'onSignAndBroadcastTxResult',
      callback: (args) {
        if (!completer.isCompleted) {
          final resultString =
              (args.isNotEmpty && args[0] is String) ? args[0] as String : null;
          final response =
              resultString != null ? jsonDecode(resultString) : null;
          completer.complete(response);
        }
      },
    );

    final opsJson = jsonEncode(operationRequest);

    final jsCode = """
    (async () => {
      try {
        const res = await signAndBroadcastTx($opsJson, "$keyType");
        window.flutter_inappwebview.callHandler('onSignAndBroadcastTxResult', JSON.stringify(res));
      } catch (e) {
        window.flutter_inappwebview.callHandler('onSignAndBroadcastTxResult', JSON.stringify({ error: e.toString() }));
      }
    })();
  """;

    await headlessWebView.webViewController?.evaluateJavascript(source: jsCode);

    return completer.future;
  }

  @override
  Future<String> subscribeUnsubscribeToCommunity(
    String communityId,
    bool subscribe,
  ) async {
    final completer = Completer<String>();

    // Remove previous handler if exists
    headlessWebView.webViewController?.removeJavaScriptHandler(
      handlerName: 'subscribeUnsubscribeToCommunityResult',
    );

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: 'subscribeUnsubscribeToCommunityResult',
      callback: (args) {
        if (!completer.isCompleted) {
          final resultString =
              (args.isNotEmpty && args[0] is String) ? args[0] as String : null;
          var jsonResult = jsonDecode(resultString ?? '{}');
          if (jsonResult['success'] == true) {
            completer.complete(jsonResult['result'] ?? 'some-id-goes-here');
            return;
          } else {
            completer.completeError(
              jsonResult['message'] ?? 'something went wrong',
            );
          }
        }
      },
    );

    final jsCode = """
    (async () => {
      try {
        const res = await subscribeUnsubscribeToCommunity("$communityId", $subscribe);
        window.flutter_inappwebview.callHandler('subscribeUnsubscribeToCommunityResult', res);
      } catch (e) {
        window.flutter_inappwebview.callHandler('subscribeUnsubscribeToCommunityResult', JSON.stringify({ error: e.toString(), success: false }));
      }
    })();
  """;

    await headlessWebView.webViewController?.evaluateJavascript(source: jsCode);
    return completer.future;
  }

  @override
  Future<String> transfer(
    String recipient,
    double amount,
    String assetSymbol,
    String? memo,
  ) async {
    await _webViewInitFuture; // Ensure WebView is initialized

    final completer = Completer<String>();
    // Unique handler name to avoid conflicts with concurrent calls
    final handlerName =
        'onTransferResult_${DateTime.now().millisecondsSinceEpoch}';

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) {
        if (!completer.isCompleted) {
          if (args.isNotEmpty && args[0] != null) {
            completer.complete(args[0].toString());
          } else {
            completer.complete(
              '{"error":"No result or null returned from JavaScript for transfer"}',
            );
          }
        }
        // Clean up the handler after completion
        headlessWebView.webViewController?.removeJavaScriptHandler(
          handlerName: handlerName,
        );
      },
    );

    // Properly escape strings for JavaScript
    final jsRecipient = jsonEncode(recipient);
    final jsAssetSymbol = jsonEncode(assetSymbol);
    final jsMemo =
        memo == null ? 'null' : jsonEncode(memo); // Handle null memo correctly

    final String jsCall = """
    (async () => {
      try {
        const result = await transfer($jsRecipient, ${amount.toString()}, $jsAssetSymbol, $jsMemo);
        // The transfer function in JS should already return a JSON string.
        window.flutter_inappwebview.callHandler('$handlerName', result || 'null');
      } catch (e) {
        // Send error back as a JSON string
        window.flutter_inappwebview.callHandler('$handlerName', JSON.stringify({ error: e.message || e.toString() }));
      }
    })();
    """;

    await headlessWebView.webViewController?.evaluateJavascript(source: jsCall);
    return completer.future;
  }

  @override
  Future<List<CommunitySubscriber>> getCommunitySubscribers(
    String community, {
    int limit = 100,
    String? last,
  }) async {
    final completer = Completer<List<CommunitySubscriber>>();
    final handlerName =
        'getCommunitySubscribersResult_${DateTime.now().millisecondsSinceEpoch}';

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) {
        if (!completer.isCompleted) {
          final contentData = args.isNotEmpty ? args[0].toString() : null;
          if (contentData != null &&
              contentData != 'null' &&
              contentData.isNotEmpty) {
            try {
              final subscribers = CommunitySubscriber.listFromJsonString(
                contentData,
              );
              completer.complete(subscribers);
            } catch (e) {
              completer.completeError('Failed to parse subscribers: $e');
            }
          } else {
            completer.completeError(
              'Failed to get subscribers or empty response',
            );
          }
        }
        headlessWebView.webViewController?.removeJavaScriptHandler(
          handlerName: handlerName,
        );
      },
    );

    final jsCommunity = jsonEncode(community);
    final jsLast = last == null ? 'null' : jsonEncode(last);

    final jsCall = """
    (async () => {
      try {
        const result = await getCommunitySubscribers($jsCommunity, $limit, $jsLast);
        window.flutter_inappwebview.callHandler('$handlerName', result || 'null');
      } catch (e) {
        window.flutter_inappwebview.callHandler('$handlerName', JSON.stringify([]));
      }
    })();
    """;

    await headlessWebView.webViewController?.evaluateJavascript(source: jsCall);
    return completer.future;
  }

  @override
  Future<List<ActiveVote>> getActiveVotes(
    String author,
    String permlink,
  ) async {
    final completer = Completer<List<ActiveVote>>();
    final handlerName =
        'onGetActiveVotesResult_${DateTime.now().millisecondsSinceEpoch}';

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) {
        if (!completer.isCompleted) {
          final contentData = args.isNotEmpty ? args[0].toString() : null;
          if (contentData != null &&
              contentData != 'null' &&
              contentData.isNotEmpty) {
            try {
              final List<dynamic> jsonList = jsonDecode(contentData);
              final votes =
                  jsonList.map((e) => ActiveVote.fromJson(e)).toList();
              completer.complete(votes);
            } catch (e) {
              completer.completeError('Failed to parse active votes: $e');
            }
          } else {
            completer.completeError(
              'Failed to get active votes or empty response',
            );
          }
        }
        headlessWebView.webViewController?.removeJavaScriptHandler(
          handlerName: handlerName,
        );
      },
    );

    final jsAuthor = jsonEncode(author);
    final jsPermlink = jsonEncode(permlink);

    final jsCall = """
    (async () => {
      try {
        const result = await getActiveVotes($jsAuthor, $jsPermlink);
        window.flutter_inappwebview.callHandler('$handlerName', result || 'null');
      } catch (e) {
        window.flutter_inappwebview.callHandler('$handlerName', JSON.stringify([]));
      }
    })();
    """;

    await headlessWebView.webViewController?.evaluateJavascript(source: jsCall);
    return completer.future;
  }

  @override
  Future<List<AccountHistoryOp>> getAccountHistory(
    String account, {
    int index = -1,
    int limit = 1000,
    String? start,
    String? stop,
  }) async {
    final completer = Completer<List<AccountHistoryOp>>();
    final handlerName =
        'onGetAccountHistoryResult_${DateTime.now().millisecondsSinceEpoch}';

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) {
        if (!completer.isCompleted) {
          final contentData = args.isNotEmpty ? args[0].toString() : null;
          if (contentData != null &&
              contentData != 'null' &&
              contentData.isNotEmpty) {
            try {
              final List<dynamic> jsonList = jsonDecode(contentData);
              final history =
                  jsonList.map((e) => AccountHistoryOp.fromJson(e)).toList();
              completer.complete(history);
            } catch (e) {
              completer.completeError('Failed to parse account history: $e');
            }
          } else {
            completer.completeError(
              'Failed to get account history or empty response',
            );
          }
        }
        headlessWebView.webViewController?.removeJavaScriptHandler(
          handlerName: handlerName,
        );
      },
    );

    final jsAccount = jsonEncode(account);
    final jsIndex = index;
    final jsLimit = limit;
    final jsStart = start == null ? 'null' : jsonEncode(start);
    final jsStop = stop == null ? 'null' : jsonEncode(stop);

    final jsCall = """
  (async () => {
    try {
      const result = await getAccountHistory($jsAccount, $jsIndex, $jsLimit, $jsStart, $jsStop);
      window.flutter_inappwebview.callHandler('$handlerName', result || 'null');
    } catch (e) {
      window.flutter_inappwebview.callHandler('$handlerName', JSON.stringify([]));
    }
  })();
  """;

    await headlessWebView.webViewController?.evaluateJavascript(source: jsCall);
    return completer.future;
  }

  @override
  Future<PendingAuthorRewardData> getPendingAuthorRewardData(
    String username,
  ) async {
    final completer = Completer<PendingAuthorRewardData>();
    final handlerName =
        'onPendingAuthorReward_${DateTime.now().millisecondsSinceEpoch}';

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) {
        if (!completer.isCompleted) {
          try {
            final contentData = args.isNotEmpty ? args[0].toString() : null;
            if (contentData != null &&
                contentData != 'null' &&
                contentData.isNotEmpty) {
              final jsonMap = jsonDecode(contentData);
              final rewardData = PendingAuthorRewardData.fromJson(jsonMap);
              completer.complete(rewardData);
            } else {
              completer.completeError('Empty or null author reward response');
            }
          } catch (e) {
            completer.completeError('Failed to parse author reward data: $e');
          }
        }

        headlessWebView.webViewController?.removeJavaScriptHandler(
          handlerName: handlerName,
        );
      },
    );

    final jsUsername = jsonEncode(username);

    final jsCall = """
    (async () => {
      try {
        const result = await getPendingAuthorRewardData($jsUsername);
        window.flutter_inappwebview.callHandler('$handlerName', result || 'null');
      } catch (e) {
        window.flutter_inappwebview.callHandler('$handlerName', JSON.stringify(null));
      }
    })();
  """;

    await headlessWebView.webViewController?.evaluateJavascript(source: jsCall);
    return completer.future;
  }

  @override
  Future<PendingCurationRewardData> getPendingCurationRewardData(
    String username,
  ) async {
    final completer = Completer<PendingCurationRewardData>();
    final handlerName =
        'onPendingCurationReward_${DateTime.now().millisecondsSinceEpoch}';

    headlessWebView.webViewController?.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) {
        if (!completer.isCompleted) {
          try {
            final contentData = args.isNotEmpty ? args[0].toString() : null;
            if (contentData != null &&
                contentData != 'null' &&
                contentData.isNotEmpty) {
              final jsonMap = jsonDecode(contentData);
              final rewardData = PendingCurationRewardData.fromJson(jsonMap);
              completer.complete(rewardData);
            } else {
              completer.completeError('Empty or null curation reward response');
            }
          } catch (e) {
            completer.completeError('Failed to parse curation reward data: $e');
          }
        }

        headlessWebView.webViewController?.removeJavaScriptHandler(
          handlerName: handlerName,
        );
      },
    );

    final jsUsername = jsonEncode(username);

    final jsCall = """
    (async () => {
      try {
        const result = await getPendingCurationRewardData($jsUsername);
        window.flutter_inappwebview.callHandler('$handlerName', result || 'null');
      } catch (e) {
        window.flutter_inappwebview.callHandler('$handlerName', JSON.stringify(null));
      }
    })();
  """;

    await headlessWebView.webViewController?.evaluateJavascript(source: jsCall);
    return completer.future;
  }

  @override
  Future<bool> isHiveKeychainAvailable() async {
    // Not available on non-web platforms by default
    return false;
  }
}
