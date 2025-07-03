import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
// import 'package:hive_flutter_kit/ux/theme_mode.dart';
import 'package:provider/provider.dart';

class PostDetailPostWebView extends StatefulWidget {
  const PostDetailPostWebView(
      {super.key, required this.width, required this.body});

  final double width;
  final String body;

  @override
  State<PostDetailPostWebView> createState() => _PostDetailPostWebViewState();
}
class _PostDetailPostWebViewState extends State<PostDetailPostWebView> {
  String? htmlString;
  late final InAppWebViewController controller;
  final hfk = HiveFlutterKitPlatform.instance;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only run once
    if (!_hasLoaded) {
      // final isDarkMode = !context.read<ThemeController>().isLightTheme();
      getHtmlAndLoad(widget.body, widget.width.toInt(), true);
      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return htmlString != null
        ? InAppWebView(
            onScrollChanged: (controller, x, y) async {
              int? offset = await controller.getContentHeight();
              log(offset.toString());
              print("$x , $y");
            },
            onWebViewCreated: (controller) => this.controller = controller,
            initialData: InAppWebViewInitialData(data: htmlString!),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  void getHtmlAndLoad(String inputString, int width, bool isDarkMode) async {
    final String result = await hfk.getHtmlFromPlatform(inputString, width);
    if (mounted) {
      String textColor = isDarkMode ? 'white' : 'black';
      String backgroundColor = isDarkMode ? 'black' : 'white';
      String fontSize = MediaQuery.of(context).size.width < 600 ? "30px" : "18px";

      htmlString = result.replaceAll(
        "<img src",
        "<img style='display: block; margin: 0 auto;' width='100%' src",
      );

      htmlString = """
        <body style='font-size: $fontSize; background-color: $backgroundColor; color: $textColor; padding: 20; font-family: Poppins' link='#FF5722'>
          $htmlString
        </body>
      """;

      setState(() {});
    }
  }
}
