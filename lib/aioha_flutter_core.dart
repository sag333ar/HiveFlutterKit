import 'aioha_flutter_core_platform_interface.dart';

class AiohaFlutterCore {
  Future<String?> getPlatformVersion() {
    return AiohaFlutterCorePlatform.instance.getPlatformVersion();
  }

  Future<String> loginWithKeychain(String username) {
    return AiohaFlutterCorePlatform.instance.loginWithKeychain(username);
  }

  Future<String> loginWithHiveAuth(String username) {
    return AiohaFlutterCorePlatform.instance.loginWithHiveAuth(username);
  }

  Future<String> getCurrentUser() {
    return AiohaFlutterCorePlatform.instance.getCurrentUser();
  }

  Future<String> getQrString() {
    return AiohaFlutterCorePlatform.instance.getQrString();
  }

  Future<String> logout() {
    return AiohaFlutterCorePlatform.instance.logout();
  }

  Future<String> singleVote(String author, String permlink, int weight) {
    return AiohaFlutterCorePlatform.instance.singleVote(
      author,
      permlink,
      weight,
    );
  }

  Future<String> comment(
    String parentAuthor,
    String parentPermlink,
    String permlink,
    String title,
    String body,
    Map<String, dynamic> jsonMetadata,
  ) {
    return AiohaFlutterCorePlatform.instance.comment(
      parentAuthor,
      parentPermlink,
      permlink,
      title,
      body,
      jsonMetadata,
    );
  }

  Future<String> commentWithOptions(
    String parentAuthor,
    String parentPermlink,
    String permlink,
    String title,
    String body,
    Map<String, dynamic> jsonMetadata,
    Map<String, dynamic> options,
  ) {
    return AiohaFlutterCorePlatform.instance.commentWithOptions(
      parentAuthor,
      parentPermlink,
      permlink,
      title,
      body,
      jsonMetadata,
      options,
    );
  }

  Future<String> deleteComment(String permlink) {
    return AiohaFlutterCorePlatform.instance.deleteComment(permlink);
  }

  Future<String> reblog(String author, String permlink, bool reblogFlag) {
    return AiohaFlutterCorePlatform.instance.reblog(
      author,
      permlink,
      reblogFlag,
    );
  }

  Future<String> follow(String author, bool followFlag) {
    return AiohaFlutterCorePlatform.instance.follow(author, followFlag);
  }
}
