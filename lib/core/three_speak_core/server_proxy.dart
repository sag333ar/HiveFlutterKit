import 'dart:async';

class Server {
  final String domain = "https://3speak.tv";

  String userOwnerThumb(String value) {
    return "https://images.hive.blog/u/$value/avatar";
  }

  String userChannelCover(String value) {
    return "https://img.3speakcontent.co/user/$value/cover.png";
  }

  String communityIcon(String value) {
    return "https://images.hive.blog/u/$value/avatar?size=icon";
  }

  String resizedImage(String value) {
    return "https://images.hive.blog/640x0/$value";
  }

  final _controller = StreamController<bool>();
  final _hiveUserDataController = StreamController<HiveUserData>();

  Stream<bool> get theme {
    return _controller.stream;
  }

  Stream<HiveUserData> get hiveUserData {
    return _hiveUserDataController.stream;
  }

  void changeTheme(bool value) async {
    _controller.sink.add(!value);
  }

  void updateHiveUserData(HiveUserData data) {
    _hiveUserDataController.sink.add(data);
  }
}

Server server = Server();


class HiveKeychainData {
  String hasId;
  String hasExpiry;
  String hasAuthKey;
  HiveKeychainData({
    required this.hasId,
    required this.hasExpiry,
    required this.hasAuthKey,
  });
}

class HiveSocketData {
  String authKey;
  String encryptedData;

  HiveSocketData({
    required this.authKey,
    required this.encryptedData,
  });
}

class HiveUserData {
  String? username;
  String? postingKey;
  String? cookie;
  String? language;
  HiveKeychainData? keychainData;
  String resolution;
  String rpc;
  String union;
  bool loaded;
  String? accessToken;
  late bool postingAuthority;

  HiveUserData(
      {required this.username,
      required this.postingKey,
      required this.keychainData,
      required this.accessToken,
      required this.cookie,
      required this.resolution,
      required this.rpc,
      required this.union,
      required this.loaded,
      required this.language,
      required String? postingAuthority,}) {
    if (postingAuthority != null) {
      this.postingAuthority = postingAuthority == 'true';
    } else {
      this.postingAuthority = false;
    }
  }
}
