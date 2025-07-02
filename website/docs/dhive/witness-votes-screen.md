---
title: Witness Votes Screen
sidebar_label: Witness Votes
slug: /dhive/witness-votes-screen
---

# Witness Votes

The **WitnessVotes** widget in `HiveFlutterKit` displays a grid of all Hive witnesses a specific user has voted for. It offers a simple, minimal UI with loading, error, and empty states, and leverages the `AccountGridView` widget to visually list usernames.

This screen is useful for governance dashboards, user profile views, and voting interfaces in Hive-based apps.

---

## UI Preview

![Witness votes screen example](/img/dhive/witness_votes.png)

## Features

- 🗳 Fetches the list of witnesses a user has voted for.
- 🧱 Renders usernames in a responsive grid view.
- 🛠 Built using `HiveFlutterKitPlatform` and `AccountGridView`.
- 🚫 Displays fallback UI for empty, error, or loading states.

---

## Usage example
```dart
late HiveFlutterKitPlatform hfk;
String username = await hfk.getCurrentUser();
WitnessVotes(
    hfk: hfk,
    account: username,
)
```
## Parameters

| Parameter       | Type                     | Required | Description                                |
| --------------- | ------------------------ | -------- | ------------------------------------------ |
| `hfk`         | `HiveFlutterKitPlatform` | ✅      | Hive platform instance for API access      |
| `account`           | `String`                   | ✅       | Hive username whose followings will be fetched and displayed.

## Constructor

```dart
WitnessVotes({
  Key? key,
  required HiveFlutterKitPlatform hfk,
  required String account,
})
