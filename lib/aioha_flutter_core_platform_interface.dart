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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
