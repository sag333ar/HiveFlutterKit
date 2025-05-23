import 'package:aioha_flutter_core/models/login_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:aioha_flutter_core/models/account.dart';
import 'package:aioha_flutter_core/models/chain_properties.dart';
import 'package:aioha_flutter_core/models/discussion.dart';
import 'package:aioha_flutter_core/models/resource_credits.dart';
import 'package:aioha_flutter_core/models/voting_power.dart';
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

  Future<LoginModel> loginWithKeychain(String username, String proof) {
    throw UnimplementedError('loginWithKeychain has not been implemented.');
  }

  Future<LoginModel> loginWithHiveAuth(String username, String proof) {
    throw UnimplementedError('loginWithHiveAuth has not been implemented.');
  }

  Future<LoginModel> loginWithPlaintextKey(
    String username,
    String postingKey,
    String proof,
  ) {
    throw UnimplementedError('loginWithPlaintextKey has not been implemented.');
  }

  Future<String> getCurrentUser() {
    throw UnimplementedError('getCurrentUser has not been implemented.');
  }

  Future<String> getQrString() {
    throw UnimplementedError('getQrString has not been implemented.');
  }

  Future<String> logout() {
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
    String jsonMetadata,
    String options,
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

  Future<String> addAccountAuthority(
    String account,
    String keyType,
    int weight,
  ) {
    throw UnimplementedError('addAccountAuthority has not been implemented.');
  }

  Future<String> removeAccountAuthority(String account, String keyType) {
    throw UnimplementedError(
      'removeAccountAuthority has not been implemented.',
    );
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<ChainProperties> getChainProperties() {
    throw UnimplementedError('getChainProperties() has not been implemented.');
  }

  Future<List<Discussion>> getDiscussions(
    String by, {
    required int limit,
    String tag = '',
    String? startAuthor,
    String? startPermlink,
    String? observer,
  }) {
    throw UnimplementedError('getDiscussions() has not been implemented.');
  }

  Future<List<Account>> getAccounts(List<String> usernames) {
    throw UnimplementedError('getAccounts() has not been implemented.');
  }

  Future<VotingPower> getVotingPower(String username) {
    throw UnimplementedError('getVotingPower() has not been implemented.');
  }

  Future<ResourceCredits> getResourceCredits(String username) {
    throw UnimplementedError('getResourceCredits() has not been implemented.');
  }

  Future<List<Discussion>> getAccountPosts(
    String username,
    String by, {
    required int limit,
    String? startAuthor,
    String? startPermlink,
    String? observer,
  }) {
    throw UnimplementedError('getAccountPosts() has not been implemented.');
  }
}
