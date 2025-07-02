---
title: Followers Screen
sidebar_label: Followers
slug: /dhive/followers-screen
---

# Followers

The **Followers** widget in `HiveFlutterKit` displays a list of users following a specific Hive account. It uses a clean, grid-based layout and supports fetching followers using the Hive blockchain's follower API.

This widget is useful for profile sections, follower analysis, or social discovery features in Hive-based apps.

---

## UI Preview

![Followers screen example](/img/dhive/followers.png)

## Features

- 🔁 Fetches followers using Hive's `follow_api`.
- 👤 Displays user avatars and usernames in a grid layout.
- 📦 Lightweight and minimal UI with optional error handling.
- 🧩 Easy integration using `HiveFlutterKitPlatform`.

---

## Usage example
```dart
late HiveFlutterKitPlatform hfk;
String username = await hfk.getCurrentUser();
Followers(
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
Followers({
  Key? key,
  required HiveFlutterKitPlatform hfk,
  required String account,
})
