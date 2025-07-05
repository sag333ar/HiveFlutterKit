---
title: 🗳️ 💰 Proposals
sidebar_label: 🗳️ 💰 Proposals
slug: /proposals-screen
---

# 🗳️ 💰 Hive Proposal Feed

The `ProposalsScreen` widget displays a list of governance proposals fetched from the Hive blockchain using the Hive Flutter Kit SDK. It supports filtering, sorting, and various user interactions including vote, stats, and support actions.

> 📘 This is part of the `DHive Governance Module`.

---

## UI Preview

![Proposals List Example](/img/dhive/proposalscreen.png)

---

## Features

- ✅ **Sorting & Filtering** — Choose filters like `Active`, `Upcoming`, `All`, and `By Peak Projects`, and sort by `Votes`, `Daily Pay`, or `End Date`.
- 📈 **Vote Metrics** — Display vote values (e.g., `1.2B HP`), remaining days, paid/to-pay HBD, and daily pay.
- 🎯 **Interactive Cards** — Tap to view user profiles, title, stats, and trigger actions like `Upvote` or `Support`.
- 🔁 **Pull-to-Refresh** — Swipe down to reload latest proposals.
- 📱 **Responsive Layout** — Adapts to both mobile and wide layouts.

---

## Feed Filters

Filter proposals using the tab bar:

- `ALL` - Show all proposals.
- `ACTIVE` - Only currently active proposals.
- `UPCOMING` - Proposals scheduled for the future.
- `BY PEAK PROJECTS` - Filtered by Peak Projects governance.

---

## Sort Options

Use the top-right dropdown to sort by:

- `VOTES` (default) — Sorts by total upvotes.
- `DAILY PAY` — Sorts by amount of HBD paid per day.
- `END DATE` — Sorts by proposal expiration date.

---

## Usage

```dart
ProposalsScreen(
  hfk: hfk, // HiveFlutterKitPlatform instance
  onTapUserAvatar: (creator) => debugPrint('Avatar tapped: $creator'),
  onTapUsername: (creator) => debugPrint('Username tapped: $creator'),
  onTapTitle: (subject, proposalId) =>
    debugPrint('Title tapped: $subject (ID: $proposalId)'),
  onTapStats: (proposalId) =>
    debugPrint('Stats tapped for proposal $proposalId'),
  onTapUpvote: (proposalId) =>
    debugPrint('Upvote tapped for $proposalId'),
  onTapVoteValue: (proposalId, voteValue) =>
    debugPrint('Vote value tapped: $voteValue for $proposalId'),
  onTapSupport: (proposalId) =>
    debugPrint('Support tapped for $proposalId'),
);
```

---

## Parameters

| Name              | Type                                            | Description                                                            |
|-------------------|--------------------------------------------------|------------------------------------------------------------------------|
| `hfk`             | `HiveFlutterKitPlatform`                        | ✅ Required. Hive SDK instance used to fetch proposals.                |
| `onTapUserAvatar` | `Function(String creator)`                      | Triggered when avatar is tapped.                                       |
| `onTapUsername`   | `Function(String creator)`                      | Triggered when username is tapped.                                     |
| `onTapTitle`      | `Function(String subject, String proposalId)`   | Triggered when proposal title is tapped.                               |
| `onTapStats`      | `Function(String proposalId)`                   | Triggered when `STATS` is tapped.                                      |
| `onTapUpvote`     | `Function(String proposalId)`                   | Triggered when upvote icon is tapped.                                  |
| `onTapVoteValue`  | `Function(String proposalId, String voteValue)` | Triggered when vote value is tapped.                                   |
| `onTapSupport`    | `Function(String proposalId)`                   | Triggered when `SUPPORT` is tapped.                                    |

---

## Models

### `Proposal`

Represents a single proposal fetched from the Hive blockchain.

```dart
class Proposal {
  final int id;
  final int proposalId;
  final String creator;
  final String receiver;
  final String permlink;
  final String subject;
  final String status;
  final String startDate;
  final String endDate;
  final String totalVotes;
  final ProposalAsset dailyPay;

  // UI & Computed Fields
  int get remainingDays;         // Days until endDate
  String get formattedVotes;     // Vote count in readable format (e.g. 1B HP)
  String get formattedDailyPay;  // e.g. 500 HBD
  String get durationText;       // e.g. 30 days
  String get statusBadgeColor;   // Color HEX code based on status
  bool get isActive;
  bool get isUpcoming;
  bool get isExpired;
}
```

---

### `ProposalAsset`

Represents the HBD payout amount with precision info.

```dart
class ProposalAsset {
  final String amount;
  final String nai;
  final int precision;

  String get formattedAmount; // Amount formatted using precision
}
```

---

## UI Elements

### Proposal Card

Each card displays:

- 👤 Avatar with creator initials
- 🏷️ Proposal title with ID
- 💬 Subject + Proposal dates
- 🗳️ Vote metrics + buttons (`Vote`, `Stats`, `Support`)
- 📅 Daily Pay, Remaining Days
- 🏷️ Status badge (`ACTIVE`, `UPCOMING`, etc.)

### Sort Dropdown

Lets users change sorting:

- `Votes`
- `Daily Pay`
- `End Date`

### Filter Tabs

Lets users filter proposals:

- `ALL`, `ACTIVE`, `UPCOMING`, `BY PEAK PROJECTS`

---

## Error & Empty State Handling

- ❌ Shows error message when proposals fail to load
- 📭 Displays `No proposals found` if list is empty
- 🔁 Retry button shown for reload

---

## Refresh Behavior

Pull-to-refresh is implemented using `RefreshIndicator`. Swiping down reloads the proposals from the Hive API.

---

## Dependencies

- ✅ `hive_flutter_kit` – for data layer and API
- ✅ `Proposal` model – with voting, pay, and metadata
- ✅ `formatDate()` – to convert ISO date strings to readable format
- ✅ `calculatePaid()` / `calculateToPay()` – for payment tracking logic
- ✅ `switchCases.dart` – to map filters and sorting logic
