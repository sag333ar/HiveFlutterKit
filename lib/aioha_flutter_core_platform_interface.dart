import 'package:aioha_flutter_core/models/current_user_model.dart';
import 'package:aioha_flutter_core/models/get_qr_string_model.dart';
import 'package:aioha_flutter_core/models/login_with_hiveauth_model.dart';
import 'package:aioha_flutter_core/models/login_with_keychain_model.dart';
import 'package:aioha_flutter_core/models/logout_user_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'aioha_flutter_core_method_channel.dart';

abstract class AiohaFlutterCorePlatform extends PlatformInterface {
  /// Constructs a AiohaFlutterCorePlatform.
  AiohaFlutterCorePlatform() : super(token: _token);
  static final Object _token = Object();

  static AiohaFlutterCorePlatform _instance = MethodChannelAiohaFlutterCore();

  /// The default instance of [AiohaFlutterCorePlatform] to use.
  ///
  /// Defaults to [MethodChannelAiohaFlutterCore].
  static AiohaFlutterCorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AiohaFlutterCorePlatform] when
  /// they register themselves.
  static set instance(AiohaFlutterCorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<LoginWithKeychainModel> loginWithKeychain(String username) {
    throw UnimplementedError('loginWithKeychain has not been implemented.');
  }

  Future<LoginWithHiveAuthModel> loginWithHiveAuth(String username) {
    throw UnimplementedError('loginWithHiveAuth has not been implemented.');
  }

  Future<CurrentUserModel> getCurrentUser() {
    throw UnimplementedError('getCurrentUser has not been implemented.');
  }

  Future<GetQrStringModel> getQrString() {
    throw UnimplementedError('getQrString has not been implemented.');
  }

  Future<LogoutResultModel> logout() {
    throw UnimplementedError('logout has not been implemented.');
  }

  Future<String> singleVote(String author, String permlink, int weight) {
    throw UnimplementedError('singleVote has not been implemented.');
  }

  Future<String> comment(
    String parentAuthor,
    String parentPermlink,
    String permlink,
    String title,
    String body,
    Map<String, dynamic> jsonMetadata,
  ) {
    throw UnimplementedError('comment has not been implemented.');
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
    throw UnimplementedError('commentWithOptions has not been implemented.');
  }

  Future<String> deleteComment(String permlink) {
    throw UnimplementedError('deleteComment has not been implemented.');
  }

  Future<String> reblog(String author, String permlink, bool reblogFlag) {
    throw UnimplementedError('reblog has not been implemented.');
  }

  Future<String> follow(String author, bool followFlag) {
    throw UnimplementedError('follow has not been implemented.');
  }

  Future<String> claimRewards() {
    throw UnimplementedError('claimRewards has not been implemented.');
  }

  Future<String> signMessage(String message, String keyType) {
    throw UnimplementedError('SignMessage has not been implemented.');
  }

  Future<bool> switchUser(String userId) {
    throw UnimplementedError('switchUser has not been implemented.');
  }

  Future<List<String>> getOtherLogins() {
    throw UnimplementedError('getOtherLogins has not been implemented.');
  }

  Future<String> removeOtherLogin(String userId) {
    throw UnimplementedError('removeOtherLogin has not been implemented.');
  }
}
