import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'aioha_flutter_core_platform_interface.dart';

/// An implementation of [AiohaFlutterCorePlatform] that uses method channels.
class MethodChannelAiohaFlutterCore extends AiohaFlutterCorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('aioha_flutter_core');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
