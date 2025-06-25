---
title: ThreeSpeak Login
sidebar_label: ThreeSpeak Login
slug: /login
---

# ThreeSpeak Login

![ThreeSpeak Login Preview](/img/threespeak/login.png)

A Flutter widget for authenticating users with 3Speak using Hive Keychain, HiveAuth, or private posting key. The `ThreeSpeakLoginScreen` provides a customizable login UI and handles the 3Speak mobile login API integration.

---

## Overview

The `ThreeSpeakLoginScreen` is a wrapper around the generic `LoginScreen` that adds 3Speak-specific login logic. It supports multiple authentication methods and calls the 3Speak `/mobile/login` API after successful Hive authentication, returning a JWT token and user info.

---

## Usage Example

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ThreeSpeakLoginScreen(
      hfk: hfk, // HiveFlutterKitPlatform.instance
      uponLogin: (context, token, username) {
        debugPrint('Logged in! Token: $token, Username: $username');
        // Navigate or store token as needed
      },
      // Optional customizations:
      title: 'Login to 3Speak',
      subtitle: 'Authenticate with Hive to continue',
      logoIcon: Icon(Icons.video_library, size: 64, color: Colors.deepPurple),
    ),
  ),
);
```

---

## Widget Parameters

| Parameter         | Type                                              | Required | Description                                                                 |
|-------------------|---------------------------------------------------|----------|-----------------------------------------------------------------------------|
| `hfk`             | `HiveFlutterKitPlatform`                          | ✅        | The HiveFlutterKit platform instance.                                       |
| `uponLogin`       | `void Function(BuildContext, String, String)`     | ✅        | Callback invoked after successful login with 3Speak token and username.      |
| `backgroundColors`| `List<Color>?`                                    | ❌        | Background gradient colors.                                                  |
| `fontColor`       | `Color?`                                          | ❌        | Font color for text.                                                         |
| `borderColor`     | `Color?`                                          | ❌        | Border color for the login card.                                             |
| `hiveKeychainButtonColor` | `Color?`                                  | ❌        | Button color for Hive Keychain login.                                        |
| `hiveKeychainTextColor`   | `Color?`                                  | ❌        | Text color for Hive Keychain button.                                         |
| `hiveAuthButtonColor`     | `Color?`                                  | ❌        | Button color for HiveAuth login.                                             |
| `hiveAuthTextColor`       | `Color?`                                  | ❌        | Text color for HiveAuth button.                                              |
| `title`           | `String?`                                         | ❌        | Title text for the login screen.                                             |
| `subtitle`        | `String?`                                         | ❌        | Subtitle text for the login screen.                                          |
| `logoIcon`        | `Widget?`                                         | ❌        | Logo widget to display above the login form.                                 |

---

## Features

### 🔑 Multiple Login Methods
- Hive Keychain (web)
- HiveAuth (QR code, mobile/web)
- Private Posting Key

### 🔄 3Speak API Integration
- Calls `/mobile/login` on `https://studio.3speak.tv` after successful Hive login.
- Returns JWT token and user info for authenticated API access.

### 🎨 Customizable UI
- Change title, subtitle, logo, and colors via widget parameters.

### 🛡️ Secure
- No keys are stored; only the JWT token is returned after authentication.

---

## Example Flow

1. User enters their Hive username.
2. Selects a login method (Keychain, HiveAuth, or Private Posting Key).
3. Completes authentication.
4. The widget calls the 3Speak `/mobile/login` API and returns a JWT token.
5. The `uponLogin` callback is triggered with the token and username.

---

## See Also

- [VideoUploadScreen](/threespeak/video-upload.md)
- [ThreeSpeakCurrentUserAccount](/threespeak/current-account.md)
- [ThreeSpeakVideoFeed](/threespeak/video-feed.md)

