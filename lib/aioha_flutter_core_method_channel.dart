import 'dart:async';
import 'dart:convert';
import 'package:aioha_flutter_core/models/login_model.dart';
import 'package:flutter/services.dart';

import 'aioha_flutter_core_platform_interface.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// An implementation of [AiohaFlutterCorePlatform] that uses method channels.
class MethodChannelAiohaFlutterCore extends AiohaFlutterCorePlatform {
  late HeadlessInAppWebView headlessWebView;
  var isWebViewRunning = false;

  MethodChannelAiohaFlutterCore() {
    initHeadlessWebView();
  }

  Future<void> initHeadlessWebView() async {
    String htmlContent = await _loadHTMLFromAssets();

    headlessWebView = HeadlessInAppWebView(
      initialData: InAppWebViewInitialData(
        data: htmlContent,
        encoding: "utf-8",
        mimeType: "text/html",
        historyUrl: WebUri.uri(Uri.parse("http://localhost")),
        baseUrl: WebUri.uri(
          Uri.parse("http://localhost"),
        ), // iOS-specific for local file access
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true, // Ensure localStorage is enabled
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
      "packages/aioha_flutter_core/web/aioha.js",
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
      (async () => {
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
}
