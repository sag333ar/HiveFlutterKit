import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class CommunityFavouriteProvider{
  final box = GetStorage();
  final String _communitiesLocalKey = '_communityLocalKey';

  List getBookmarkedCommunities() {
    final String key = _communitiesLocalKey;
    if (box.read(key) != null) {
      List items = box.read(key);
      return items;
    } else {
      return [];
    }
  }

  bool isUserPresentLocally(String communityId) {
    final String key = _communitiesLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element == communityId);
      return index != -1;
    } else {
      return false;
    }
  }

  void storeLikedCommunityLocally(String communityId, {bool forceRemove = false}) {
    final String key = _communitiesLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element == communityId);
      if (index == -1 && !forceRemove) {
        json.add(communityId);
        box.write(key, json);
      } else {
        json.removeWhere((element) => element == communityId);
        box.write(key, json);
      }
    } else {
      box.write(key, [communityId]);
    }
    print(box.read(key));
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}