import 'package:aioha_flutter_core/aioha_flutter_core.dart';

class AiohaCore {
  final plugin = AiohaFlutterCore();

  // Private constructor
  AiohaCore._internal();

  // The single instance
  static final AiohaCore _instance = AiohaCore._internal();

  factory AiohaCore() {
    return _instance;
  }
}
