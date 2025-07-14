---
sidebar_position: 2
title: 🏁 🧑‍💻 Basic Usage
sidebar_label: 🏁 🧑‍💻 Basic Usage
---

# 🏁 🧑‍💻 Basic Usage Guide

Here's a simple example of how to use HiveFlutterKit in your Flutter widget. This example demonstrates how to access the hfk instance and call a login method.

# 🔐 Hive Login

The `LoginScreen` is a flexible authentication widget that supports multiple login methods for the Hive blockchain. It features automatic theme detection, dynamic UI customization, and real-time user avatar display. The widget handles the complete authentication flow and provides callbacks for successful login events.

## UI Preview
![Hive Login Preview](/img/dhive/hive_login.png)
![Hive Login Preview](/img/dhive/posting_key_login.png)

## Usage Example

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LoginScreen(
      hfk: HiveFlutterKitPlatform.instance, // Your HiveFlutterKitPlatform instance
      uponLogin: (context, result) {
        // This callback is triggered after successful authentication
        debugPrint('Login successful! Username: ${result.username}');
        debugPrint('Public Key: ${result.publicKey}');
        
        // Navigate to your app's main screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainScreen(user: result)),
        );
      },
      // Optional UI customizations:
      title: 'Welcome to MyApp',
      subtitle: 'Connect with your Hive account',
      logoIcon: Image.asset('assets/my_logo.png', height: 64),
      backgroundColors: [Colors.blue.shade900, Colors.purple.shade900],
      fontColor: Colors.white,
      borderColor: Colors.cyan,
      hiveKeychainButtonColor: Colors.green,
      hiveAuthButtonColor: Colors.orange,
      privatePostingKeyButtonColor: Colors.purple,
      proof: 'MyApp-${DateTime.now().millisecondsSinceEpoch}',
    ),
  ),
);
```
