---
title: Witnesses Screen
sidebar_label: Witnesses
slug: /dhive/witnesses-screen
---

# ✅ Witnesses Screen

The **WitnessesScreen** widget in `HiveFlutterKit` displays a ranked list of Hive blockchain witnesses. This screen is ideal for users who want to explore, learn about, or interact with top Hive witnesses based on vote count.

Each witness entry includes a profile picture, name, about/bio (from metadata), a link icon, and a checkmark showing whether the current user has approved the witness. The widget also supports optional callbacks for interaction.

---

## Features

- Ranks witnesses based on total vote weight.
- Displays avatars, usernames, and bios.
- Indicates whether the user has approved each witness.
- Provides optional callbacks for user interaction.

---

## UI Preview

![Witnesses Screen Example](/img/dhive/witnesses.png)

---

## Parameters

| Parameter                    | Type                        | Required | Description                                                      |
|------------------------------|-----------------------------|----------|------------------------------------------------------------------|
| `hfk`         | `HiveFlutterKitPlatform` | ✅      | Hive platform instance used for fetching witnesses |
| `onTapWitness`                        | `void Function(Account account)?`    | ❌       | Called when the user taps the entire witness row/tile   |
| `onTapLink`                     | `void Function(Account account)?`              | ❌       | Called when the user taps the link icon next to the username.                                      |
| `onTapCheckmark` | `void Function(Account account)?`                      | ❌       | Called when the user taps the green/gray checkmark icon (vote indicator).                   |

## Usage Example

```dart
Witnesses(
  hfk: hfk,
  onTapWitness: (account) => print("Tapped on ${account.name}"),
  onTapLink: (account) => print("Link clicked for ${account.name}"),
  onTapCheckmark: (account) => print("Checkmark tapped for ${account.name}",
  ),
),

