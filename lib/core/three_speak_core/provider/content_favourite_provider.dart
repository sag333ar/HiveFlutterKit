import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class ContentFavoriteProvider {
  final box = GetStorage();
  final String _contentLocalKey = '_contentLocalKey';

  List getBookmarkedUsers() {
    final String key = _contentLocalKey;
    if (box.read(key) != null) {
      List items = box.read(key);
      return items;
    } else {
      return [];
    }
  }

  //check if the liked podcast single episode is present locally
  bool isContentPresentLocally(String author, String permlink) {
    final String key = _contentLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element == '$author/$permlink');
      return index != -1;
    } else {
      return false;
    }
  }

  //sotre the single podcast episode locally if user likes it
  void storeLikedContentLocally(
    String author,
    String permlink, {
    bool forceRemove = false,
  }) {
    final String key = _contentLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element == '$author/$permlink');
      if (index == -1 && !forceRemove) {
        json.add('$author/$permlink');
        box.write(key, json);
      } else {
        json.removeWhere((element) => element == '$author/$permlink');
        box.write(key, json);
      }
    } else {
      box.write(key, ['$author/$permlink']);
    }
    debugPrint(box.read(key));
  }
}
