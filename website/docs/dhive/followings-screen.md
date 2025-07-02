---
title: Followings Screen
sidebar_label: Followings
slug: /dhive/followings-screen
---

# Followings

The **Followings** widget in `HiveFlutterKit` displays a list of accounts followed by a specific Hive user. It uses a grid-based layout to show profile avatars and usernames, making it ideal for account exploration, profile views, and social graph features.

---

## UI Preview

![Followings screen example](/img/dhive/followings.png)

## Features

- 🔎 Fetches the list of accounts the user is following.
- 🧱 Displays data in a responsive, scrollable grid layout.
- 🖼️ Includes usernames and profile images.
- ⚙️ Built using `HiveFlutterKitPlatform` for Hive blockchain access.
- 🧩 Uses `AccountGridView` for efficient layout rendering.

---

## Usage example
```dart
late HiveFlutterKitPlatform hfk;
String username = await hfk.getCurrentUser();
Followings(
    hfk: hfk,
    account: username,
)
```

## Parameters

| Parameter       | Type                     | Required | Description                                |
| --------------- | ------------------------ | -------- | ------------------------------------------ |
| `hfk`         | `HiveFlutterKitPlatform` | ✅      | Hive platform instance for API access      |
| `account`           | `String`                   | ✅       | Hive username whose followings will be fetched and displayed.                         |

## Constructor

```dart
Followings({
  Key? key,
  required HiveFlutterKitPlatform hfk,
  required String account,
})
