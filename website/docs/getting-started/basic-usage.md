---
sidebar_position: 2
title: Basic Usage
sidebar_label: Basic Usage
---

# Basic Usage Guide

Here's a simple example of how to use HiveFlutterKit in your Flutter widget. This example demonstrates how to access the AIOHA instance and call a login method.

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart'; // Ensure correct import
import 'package:provider/provider.dart'; // If using Provider

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late HiveFlutterKitPlatform aioha;
  final _usernameController = TextEditingController(); // For username input
  String _loginResult = ''; // To display login result

  @override
  void initState() {
    super.initState();
    // It's often better to get the provider instance in initState or didChangeDependencies
    // if you need it early and it doesn't depend on BuildContext that changes often.
    // However, for simplicity in this example, if context is truly needed:
    // aioha = Provider.of<HiveFlutterKitPlatform>(context, listen: false);
    // But since it's not used in initState here, we'll get it in the method.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize aioha here if it depends on context and might change
    aioha = Provider.of<HiveFlutterKitPlatform>(context, listen: false);
  }

  void _loginWithHiveKeychain() async {
    if (_usernameController.text.isEmpty) {
      setState(() {
        _loginResult = 'Please enter a username.';
      });
      return;
    }
    try {
      // The 'proof' can be any string. If empty, some implementations might auto-generate it.
      // For security, it's often a challenge string obtained from a server or a timestamp.
      final result = await aioha.loginWithKeychain(
        _usernameController.text,
        'some-text-to-be-signed',
      );
      setState(() {
        // Assuming LoginModel has a meaningful toString or specific fields
        _loginResult = 'Login Success: ${result.toJson()}';
      });
    } catch (e) {
      setState(() {
        _loginResult = 'Login Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HiveFlutterKit Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Hive Username',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithHiveKeychain,
              child: Text('Login with Hive Keychain'),
            ),
            SizedBox(height: 20),
            Text('Result: $_loginResult'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
```
