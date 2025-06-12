import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class ContentFavoriteProvider {
  final box = GetStorage();
  final String _contentLocalKey = '_contentLocalKey';

  List<String> getBookmarkedContent() {
    final List<dynamic>? stored = box.read<List<dynamic>>(_contentLocalKey);
    return stored?.map((e) => e.toString()).toList() ?? [];
  }

  /// Check if the content (author/permlink) is already bookmarked
  bool isContentPresentLocally(String author, String permlink) {
    final String key = _contentLocalKey;
    final List<dynamic>? json = box.read<List<dynamic>>(key);
    if (json != null) {
      return json.contains('$author/$permlink');
    }
    return false;
  }

  /// Store or remove liked content (based on author/permlink)
  void storeLikedContentLocally(
    String author,
    String permlink, {
    bool forceRemove = false,
  }) {
    final String key = _contentLocalKey;
    final List<dynamic>? raw = box.read<List<dynamic>>(key);
    List<String> json = raw?.map((e) => e.toString()).toList() ?? [];

    final String entry = '$author/$permlink';

    if (!json.contains(entry) && !forceRemove) {
      json.add(entry);
    } else {
      json.remove(entry);
    }

    box.write(key, json);
    debugPrint("Updated bookmarks: $json");
  }
}
