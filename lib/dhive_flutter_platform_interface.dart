import 'package:aioha_flutter_core/models/account.dart';
import 'package:aioha_flutter_core/models/chain_properties.dart';
import 'package:aioha_flutter_core/models/discussion.dart';
import 'package:aioha_flutter_core/models/resource_credits.dart';
import 'package:aioha_flutter_core/models/voting_power.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dhive_flutter_method_channel.dart';

abstract class DhiveFlutterPlatform extends PlatformInterface {
  /// Constructs a DhiveFlutterPlatform.
  DhiveFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static DhiveFlutterPlatform instance = MethodChannelDhiveFlutter();

  /// The default instance of [DhiveFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelDhiveFlutter].
  // static DhiveFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DhiveFlutterPlatform] when
  /// they register themselves.

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
