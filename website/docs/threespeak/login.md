---
title: 🎬 🔐 ThreeSpeak Login
sidebar_label: 🎬 🔐 ThreeSpeak Login
slug: /login
---

# 🎬 🔐 ThreeSpeak Login

![ThreeSpeak Login Preview](/img/threespeak/login.png)

A Flutter widget for authenticating users with 3Speak using Hive Keychain, HiveAuth, or a private posting key. The `ThreeSpeakLoginScreen` provides a customizable login UI and handles the 3Speak mobile login API integration.

---

## Overview

The `ThreeSpeakLoginScreen` is a wrapper around the generic `LoginScreen` (from `hive_flutter_kit`) that adds 3Speak-specific login logic. After a user successfully authenticates with their Hive account (using Keychain, HiveAuth, or a plaintext posting key), this widget communicates with the 3Speak API (`/mobile/login`) to obtain a JWT token. This token can then be used for subsequent authenticated requests to the 3Speak platform.

The widget includes a back button for easy navigation and displays loading indicators and error messages during the API communication process.

---

## Usage Example

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ThreeSpeakLoginScreen(
      hfk: HiveFlutterKitPlatform.instance, // Your HiveFlutterKitPlatform instance
      uponLogin: (context, token, username) {
        // This callback is triggered after a successful 3Speak login.
        // 'token' is the JWT token from 3Speak.
        // 'username' is the Hive username of the logged-in user.
        debugPrint('Logged in to 3Speak! Token: $token, Username: $username');

        // Example: Navigate to another screen or store the token securely.
        Navigator.of(context).pop(); // Pop the login screen
        // Navigator.push(context, MaterialPageRoute(builder: (_) => YourNextScreen(token: token, username: username)));
      },
      // Optional UI customizations:
      title: 'Welcome to MyApp powered by 3Speak',
      subtitle: 'Please log in with your Hive account',
      logoIcon: Image.asset('assets/my_app_logo.png', height: 64), // Example custom logo
      backgroundColors: [Colors.blueGrey.shade800, Colors.blueGrey.shade900],
      fontColor: Colors.white,
      borderColor: Colors.tealAccent,
      hiveKeychainButtonColor: Colors.redAccent,
      hiveAuthButtonColor: Colors.lightBlueAccent,
    ),
  ),
);
```

---

## Widget Parameters

| Parameter               | Type                                                          | Required | Description                                                                                                |
|-------------------------|---------------------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------|
| `hfk`                   | `HiveFlutterKitPlatform`                                      | ✅        | The `HiveFlutterKitPlatform` instance, used for Hive authentication.                                         |
| `uponLogin`             | `Function(BuildContext context, String token, String username)?`| ✅        | Callback invoked after successful login with 3Speak, providing the JWT token and username.                 |
| `backgroundColors`      | `List<Color>?`                                                | ❌        | A list of colors for the background gradient of the underlying `LoginScreen`. Defaults to a standard theme.    |
| `fontColor`             | `Color?`                                                      | ❌        | Font color for text elements within the `LoginScreen`.                                                       |
| `borderColor`           | `Color?`                                                      | ❌        | Border color for the login card within the `LoginScreen`.                                                      |
| `hiveKeychainButtonColor`| `Color?`                                                      | ❌        | Background color for the Hive Keychain login button.                                                         |
| `hiveKeychainTextColor` | `Color?`                                                      | ❌        | Text color for the Hive Keychain login button.                                                               |
| `hiveAuthButtonColor`   | `Color?`                                                      | ❌        | Background color for the HiveAuth login button.                                                                |
| `hiveAuthTextColor`     | `Color?`                                                      | ❌        | Text color for the HiveAuth login button.                                                                    |
| `title`                 | `String?`                                                     | ❌        | Custom title text displayed on the login screen. Defaults to 'Welcome to 3Speak'.                            |
| `subtitle`              | `String?`                                                     | ❌        | Custom subtitle text displayed below the title. Defaults to 'Login to continue'.                             |
| `logoIcon`              | `Widget?`                                                     | ❌        | A custom widget (e.g., `Icon` or `Image`) to display as a logo. Defaults to a video library icon.        |

---

## Features

### 🔑 Multiple Hive Login Methods
Leverages `LoginScreen` to support:
- Hive Keychain (primarily for web environments)
- HiveAuth (using QR codes, suitable for mobile and web)
- Private Posting Key (direct input, use with caution)

### 🔄 Seamless 3Speak API Integration
- Automatically handles the call to the 3Speak `/mobile/login` endpoint at `https://studio.3speak.tv` after successful Hive authentication.
- Retrieves and provides a JWT token specific to the 3Speak platform.

### 🎨 Customizable User Interface
- Offers various parameters to customize the appearance, including background, text colors, button colors, title, subtitle, and logo.
- Sensible default values are provided for a quick setup.

### ↩️ Navigation
- Includes a standard back button in the top-left corner for easy dismissal if the screen is part of a navigation stack.

### ⏳ User Feedback
- Displays a loading indicator while communicating with the 3Speak API.
- Shows `SnackBar` messages for errors encountered during the 3Speak login process (e.g., API errors, missing token).

### 🛡️ Security Note
- The widget facilitates the authentication process. Secure storage and management of the obtained JWT token are the responsibility of the consuming application.

---

## Workflow

1. The `ThreeSpeakLoginScreen` is presented to the user.
2. The user enters their Hive username and chooses a login method (Hive Keychain, HiveAuth, or Plaintext Key) via the embedded `LoginScreen`.
3. The user completes the Hive authentication process.
4. If Hive authentication is successful, `ThreeSpeakLoginScreen` takes the `LoginModel` result.
5. A loading dialog is shown.
6. The widget makes an API call to `https://studio.3speak.tv/mobile/login` with the authentication details.
7. If the 3Speak API call is successful and returns a token:
    a. The loading dialog is dismissed.
    b. The `uponLogin` callback is triggered, passing the `BuildContext`, the 3Speak JWT `token`, and the `username`.
    c. The `ThreeSpeakLoginScreen` is typically popped from the navigation stack by the `uponLogin` callback or subsequent logic.
8. If the 3Speak API call fails:
    a. The loading dialog is dismissed.
    b. A `SnackBar` is shown with an error message.

---

## See Also

- [VideoUploadScreen](/docs/video-upload) - For uploading videos after logging in.
- [ThreeSpeakCurrentUserAccount](/docs/current-account) - For managing the logged-in user's 3Speak content.
- [ThreeSpeakVideoFeed](/docs/video-feed) - For displaying various video feeds.
- `LoginScreen` (from `hive_flutter_kit`) - The base widget used for Hive authentication.

