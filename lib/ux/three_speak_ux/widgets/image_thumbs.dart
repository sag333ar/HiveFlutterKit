import 'package:flutter/material.dart';

extension ImageThumb on BuildContext {
  String userOwnerThumb(String value) {
    return "https://images.hive.blog/u/$value/avatar?id=test";
  }

  String resizedImage(String value, {int? width, int? height}) {
    return "https://images.hive.blog/${width ?? 320}x${height ?? 160}/$value";
  }

  String proxyImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return 'https://images.hive.blog/1000x0/$url';
    }
    return "";
  }

  String postHiveClient(String author, String permlink) {
    return "https://hive.blog/@$author/$permlink";
  }

  String userHiveClient(String author) {
    return "https://hive.blog/@$author";
  }
}
