import 'package:aioha_flutter_core/aioha_flutter_core_platform_interface.dart';
import 'package:aioha_flutter_core/dhive_flutter_platform_interface.dart';
import 'package:aioha_flutter_core_example/home.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider<AiohaFlutterCorePlatform>.value(
          value: AiohaFlutterCorePlatform.instance,
        ),
        Provider<DhiveFlutterPlatform>.value(
          value: DhiveFlutterPlatform.instance,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: MyHomePage(),
      ),
    );
  }
}
