import 'dart:async';
import 'dart:convert';

import 'package:aioha_flutter_core/models/account.dart';
import 'package:aioha_flutter_core/models/chain_properties.dart';
import 'package:aioha_flutter_core/models/discussion.dart';
import 'package:aioha_flutter_core/models/resource_credits.dart';
import 'package:aioha_flutter_core/models/voting_power.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'dhive_flutter_platform_interface.dart';

/// An implementation of [DhiveFlutterPlatform] that uses method channels.
class MethodChannelDhiveFlutter extends DhiveFlutterPlatform {
  late HeadlessInAppWebView headlessWebView;
  var isWebViewRunning = false;

  MethodChannelDhiveFlutter() {
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
    String html = await rootBundle.loadString(
      "packages/aioha_flutter_core/web/aioha.js",
    );
    String longHtml = """
<html>
<head><title>Dhive Flutter</title></head>
<body>
  <script src="https://unpkg.com/@hiveio/dhive@latest/dist/dhive.js"></script>
  <script>
  $html
  </script>
  </body>
  </html>
   """;
    return longHtml;
  }

  @visibleForTesting
  final methodChannel = const MethodChannel('dhive_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
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
}
