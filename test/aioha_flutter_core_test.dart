import 'package:flutter_test/flutter_test.dart';
import 'package:aioha_flutter_core/aioha_flutter_core.dart';
import 'package:aioha_flutter_core/aioha_flutter_core_platform_interface.dart';
import 'package:aioha_flutter_core/aioha_flutter_core_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAiohaFlutterCorePlatform
    with MockPlatformInterfaceMixin
    implements AiohaFlutterCorePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AiohaFlutterCorePlatform initialPlatform = AiohaFlutterCorePlatform.instance;

  test('$MethodChannelAiohaFlutterCore is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAiohaFlutterCore>());
  });

  test('getPlatformVersion', () async {
    AiohaFlutterCore aiohaFlutterCorePlugin = AiohaFlutterCore();
    MockAiohaFlutterCorePlatform fakePlatform = MockAiohaFlutterCorePlatform();
    AiohaFlutterCorePlatform.instance = fakePlatform;

    expect(await aiohaFlutterCorePlugin.getPlatformVersion(), '42');
  });
}
