---
title: 🏁 🔐 Hive Login
sidebar_label: 🏁 🔐 Hive Login
slug: /hive-login
---

# 🏁 🔐 Hive Login

The `LoginScreen` is a flexible authentication widget that supports multiple login methods for the Hive blockchain. It features automatic theme detection, dynamic UI customization, and real-time user avatar display. The widget handles the complete authentication flow and provides callbacks for successful login events.

## UI Preview
![Hive Login Preview](/img/dhive/hive_login.png)
![Hive Login Preview](/img/dhive/posting_key_login.png)

Key features include:
- **Multi-platform support**: Works on web, mobile, and desktop
- **Auto theme detection**: Automatically adapts to light/dark mode
- **Real-time avatar display**: Shows user avatar as they type their username
- **Input validation**: Sanitizes usernames according to Hive standards
- **QR code integration**: Built-in QR code display for HiveAuth
- **Keychain detection**: Automatically detects Hive Keychain availability

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/hive_flutter_kit_platform_interface.dart';
import 'package:hive_flutter_kit/core/models/login_model.dart';
import 'package:hive_flutter_kit/ux/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage(title: 'Flutter Demo Home Page'));
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});
  String generateUtcIsoTimestamp() {
    return '${DateTime.now().toUtc().toIso8601String()}Z';
  }

  @override
  Widget build(BuildContext context) {
    final hfk = HiveFlutterKitPlatform.instance;
    return Scaffold(
      body: SafeArea(
        child: LoginScreen(
          hfk: hfk,
          backgroundColors: const [Color(0xFF378CE0), Color(0xFF422E5D)],
          fontColor: Colors.white,
          // ignore: deprecated_member_use
          borderColor: Colors.white.withOpacity(0.3),
          hiveKeychainButtonColor: Colors.green,
          hiveKeychainTextColor: Colors.white,
          hiveAuthButtonColor: Colors.orange,
          hiveAuthTextColor: Colors.white,
          title: "The Tesing App",
          subtitle: "Choose your login method",
          logoIcon: Image.asset('assets/logo.png', height: 150, width: 150),
          proof: generateUtcIsoTimestamp(),
          uponLogin: (context, result) async {
            if (result is LoginModel) {
              debugPrint(
                "result- ${result.challenge}, ${result.proof}, ${result.publicKey}, ${result.username}",
              );
            }
          },
        ),
      ),
    );
  }
}
```

---

## Widget Parameters

| Parameter                              | Type                                                  | Required | Default                           | Description                                                                                    |
|----------------------------------------|-------------------------------------------------------|----------|-----------------------------------|------------------------------------------------------------------------------------------------|
| `hfk`                                  | `HiveFlutterKitPlatform`                             | ✅        | -                                 | The HiveFlutterKitPlatform instance for Hive authentication operations.                       |
| `uponLogin`                            | `Function(BuildContext context, dynamic result)?`    | ❌        | `null`                            | Callback invoked after successful login with authentication result.                           |
| `backgroundColors`                     | `List<Color>?`                                       | ❌        | Auto-detected theme colors        | Colors for the background gradient. Adapts to light/dark mode if not specified.               |
| `fontColor`                            | `Color?`                                             | ❌        | Auto-detected theme color         | Text color that automatically adapts to theme.                                                |
| `borderColor`                          | `Color?`                                             | ❌        | Auto-detected theme color         | Border color for UI elements.                                                                 |
| `hiveKeychainButtonColor`              | `Color?`                                             | ❌        | `Colors.green` (theme-adaptive)   | Background color for the Hive Keychain button.                                                |
| `hiveKeychainTextColor`                | `Color?`                                             | ❌        | `Colors.white`                    | Text color for the Hive Keychain button.                                                      |
| `hiveAuthButtonColor`                  | `Color?`                                             | ❌        | `Colors.orange` (theme-adaptive)  | Background color for the HiveAuth button.                                                     |
| `hiveAuthTextColor`                    | `Color?`                                             | ❌        | `Colors.white`                    | Text color for the HiveAuth button.                                                           |
| `privatePostingKeyButtonColor`         | `Color?`                                             | ❌        | `Colors.deepPurple` (theme-adaptive) | Background color for the private posting key button.                                       |
| `privatePostingKeyTextColor`           | `Color?`                                             | ❌        | `Colors.white`                    | Text color for the private posting key button.                                                |
| `withoutPrivatePostingKeyButtonColor`  | `Color?`                                             | ❌        | `Colors.grey` (theme-adaptive)    | Background color for the back button in posting key mode.                                     |
| `withoutPrivatePostingKeyTextColor`    | `Color?`                                             | ❌        | `Colors.white`                    | Text color for the back button in posting key mode.                                           |
| `title`                                | `String`                                             | ❌        | `'Welcome to Hive'`               | Main title displayed on the login screen.                                                     |
| `subtitle`                             | `String`                                             | ❌        | `'Choose your login method'`      | Subtitle text displayed below the title.                                                      |
| `logoIcon`                             | `Widget`                                             | ❌        | Hexagon outline icon              | Custom widget to display as a logo (Icon, Image, etc.).                                       |
| `logoImagePath`                        | `String?`                                            | ❌        | `null`                            | Path to a logo image asset. Takes precedence over `logoIcon` if provided.                     |
| `proof`                                | `String`                                             | ❌        | `''`                              | Proof string for authentication verification.                                                  |

---

## Authentication Methods

### 🔑 Hive Keychain
- **Platform**: Web only (automatically hidden on mobile)
- **Description**: Browser extension-based authentication
- **Availability**: Automatically detected on web platforms
- **User Experience**: Single-click authentication after username entry

### 📱 HiveAuth
- **Platform**: All platforms (web, mobile, desktop)
- **Description**: QR code-based authentication using mobile app
- **Features**:
  - Real-time QR code generation
  - 30-second countdown timer
  - Clickable QR code for direct app opening
  - Progress indicator
  - Cancel authentication option

### 🔐 Private Posting Key
- **Platform**: All platforms
- **Description**: Direct posting key input
- **Security**: Input field is obscured for privacy
- **Validation**: Validates both username and posting key presence
- **UI Flow**: Toggle between main login and posting key input modes

---

## Workflow

### Standard Login Flow
1. User enters Hive username
2. Avatar loads automatically
3. User selects authentication method:
   - **Keychain**: Direct authentication (web only)
   - **HiveAuth**: QR code scan and mobile app authentication
   - **Private Key**: Switch to posting key input mode

### Posting Key Login Flow
1. User clicks "Private Posting Key" button
2. Interface switches to posting key mode
3. User enters username and posting key
4. User clicks "Login with Private Posting Key"
5. Option to return to standard login methods

### HiveAuth Flow
1. User enters username and clicks "Hive Auth"
2. QR code generates and displays
3. 30-second countdown timer starts
4. User scans QR code with HiveAuth mobile app
5. Authentication completes automatically or times out

---

## Customization Examples

### Dark Theme Setup
```dart
LoginScreen(
  hfk: hiveFlutterKit,
  backgroundColors: [Color(0xFF121212), Color(0xFF1E1E1E)],
  fontColor: Colors.white,
  borderColor: Colors.white24,
  hiveKeychainButtonColor: Colors.green.shade800,
  hiveAuthButtonColor: Colors.orange.shade800,
  privatePostingKeyButtonColor: Colors.purple.shade800,
  title: 'Welcome Back',
  subtitle: 'Sign in to continue',
  uponLogin: (context, result) {
    // Handle successful login
  },
)
```

### Custom Branding
```dart
LoginScreen(
  hfk: hiveFlutterKit,
  logoImagePath: 'assets/images/company_logo.png',
  title: 'MyApp Login',
  subtitle: 'Connect with your Hive account',
  backgroundColors: [Colors.blue.shade900, Colors.indigo.shade900],
  hiveKeychainButtonColor: Colors.teal,
  hiveAuthButtonColor: Colors.amber,
  privatePostingKeyButtonColor: Colors.deepOrange,
  proof: 'MyApp-${DateTime.now().millisecondsSinceEpoch}',
  uponLogin: (context, result) {
    // Custom login handling
  },
)
```