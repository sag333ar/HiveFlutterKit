---
sidebar_position: 2
title: 🏁 🧑‍💻 Basic Usage
sidebar_label: 🏁 🧑‍💻 Basic Usage
---

# 🏁 🧑‍💻 Basic Usage Guide

Here's a simple example of how to use HiveFlutterKit in your Flutter widget. This example demonstrates how to access the hfk instance and call a login method.

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/hive_flutter_kit.dart'; // Ensure correct import

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  HiveFlutterKitPlatform hfk = HiveFlutterKitPlatform.instance;
  final _usernameController = TextEditingController(); // For username input
  String _loginResult = ''; // To display login result

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
      final result = await hfk.loginWithKeychain(
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
