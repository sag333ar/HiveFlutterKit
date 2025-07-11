import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController postingKeyController;
  final VoidCallback onLoginWithHiveKeychain;
  final VoidCallback onLoginWithHiveAuth;
  final VoidCallback onLoginWithPlaintextKey;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.postingKeyController,
    required this.onLoginWithHiveKeychain,
    required this.onLoginWithHiveAuth,
    required this.onLoginWithPlaintextKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: postingKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Posting Key (for plaintext login)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onLoginWithHiveKeychain,
          child: const Text('Login with Hive Keychain'),
        ),
        ElevatedButton(
          onPressed: onLoginWithHiveAuth,
          child: const Text('Login with HiveAuth'),
        ),
        ElevatedButton(
          onPressed: onLoginWithPlaintextKey,
          child: const Text('Login with Plaintext Key'),
        ),
      ],
    );
  }
}
