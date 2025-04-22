
import 'aioha_flutter_core_platform_interface.dart';

class AiohaFlutterCore {
  Future<String?> getPlatformVersion() {
    return AiohaFlutterCorePlatform.instance.getPlatformVersion();
  }
}
