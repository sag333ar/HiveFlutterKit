import 'package:aioha_flutter_core_example/aioha_core.dart';
import 'package:aioha_flutter_core_example/home.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(
    Provider<AiohaCore>.value(
      value: AiohaCore(), // uses your factory constructor (singleton)
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
