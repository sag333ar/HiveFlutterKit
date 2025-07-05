---
title: 👤 🪪 DHive - User's Wallet
sidebar_label: 👤 🪪 Wallet
slug: /wallet-screen
---

# 👤 🪪 DHive - User's Wallet

The `Wallet` widget displays a Hive account’s wallet data including token balances, savings, and Hive Power. This screen fetches wallet data using the Hive Flutter Kit SDK and renders a fully customizable UI with light/dark mode awareness.

> 📘 This is part of the [DHive User Wallet Module](/dhive-wallet).

---

## Screenshot

![Wallet Screen Example](/img/dhive/walletscreen.png)

---

## Features

- ✅ **Wallet Overview** — Displays balances for HIVE, HBD, savings, Hive Power, and total estimated value.
- 🎨 **Theme Customization** — Customizable colors for every wallet item and app bar.
- ⚡ **Adaptive Layout** — Mobile-optimized with gradient backgrounds and card-based layout.
- 🚨 **Error State Handling** — Displays inline card for wallet-specific errors (e.g., fetch failure).
- 🌙 **Dark Mode Support** — Auto-adjusts background and card styles for light/dark themes.

---

## Usage

```dart
Wallet(
  hfk: hfk, // HiveFlutterKit instance
  username: 'sagarkothari88', // optional, defaults to 'sagarkothari88'
  backgroundColors: [Colors.white, Colors.grey.shade100],
  fontColor: Colors.black,
  cardColor: Colors.white,
  balanceColor: Colors.blue.shade100,
  hbdColor: Colors.green.shade100,
  savingsColor: Colors.amber.shade100,
  savingsHbdColor: Colors.purple.shade100,
  powerColor: Colors.orange.shade100,
  estimatedValueColor: Colors.blue.shade700,
  errorColor: Colors.red.shade50,
  appBarColor: Colors.blue.shade700,
);
```

---

## Parameters

| Name                  | Type                 | Description                                                                 |
|-----------------------|----------------------|-----------------------------------------------------------------------------|
| `hfk`                 | `HiveFlutterKitPlatform` | ✅ Required. Hive SDK instance used to fetch wallet data.               |
| `username`            | `String?`             | Hive username to fetch wallet for. Defaults to `sagarkothari88`.           |
| `backgroundColors`    | `List<Color>?`        | Gradient background colors. Adjusted automatically if null.                |
| `fontColor`           | `Color?`              | Color used for all text labels and amounts.                                |
| `cardColor`           | `Color?`              | Background color of balance cards.                                         |
| `balanceColor`        | `Color?`              | Color for the HIVE balance icon background.                                |
| `hbdColor`            | `Color?`              | Color for the HBD balance icon background.                                 |
| `savingsColor`        | `Color?`              | Color for HIVE savings icon background.                                    |
| `savingsHbdColor`     | `Color?`              | Color for HBD savings icon background.                                     |
| `powerColor`          | `Color?`              | Color for Hive Power icon background.                                      |
| `estimatedValueColor` | `Color?`              | Color for the estimated value total.                                       |
| `errorColor`          | `Color?`              | Background color of the error card.                                        |
| `appBarColor`         | `Color?`              | AppBar background color.                                                   |

---

## Model: `WalletData`

```dart
class WalletData {
  final String? balance;            // Liquid HIVE balance
  final String? hbdBalance;         // Liquid HBD balance
  final String? savingsBalance;     // Savings in HIVE
  final String? savingsHbdBalance;  // Savings in HBD
  final String? hivePower;          // Vested HP amount
  final String? estimatedValue;     // Approx total wallet value in USD
  final String? error;              // Optional error message if API fails
}
```

### Factory Constructors

- `WalletData.fromJson(Map<String, dynamic>)`: Parses response JSON.
- `WalletData.fallback({String? error})`: Default fallback values with optional error.

---

## UI Elements

### AppBar

- Displays the `Wallet` title.
- Customizable via `appBarColor` and `fontColor`.

### Estimated Value Card

- Large top card showing total account value (e.g., `$123.45`).
- Highlighted using `estimatedValueColor`.

### Balance Tiles

Each `_walletTile` displays:

| Field                | Label Text       | Icon                            |
|----------------------|------------------|----------------------------------|
| `balance`            | `Balance`        | `Icons.account_balance_wallet`  |
| `hbdBalance`         | `HBD Balance`    | `Icons.monetization_on`         |
| `savingsBalance`     | `Savings Balance`| `Icons.savings`                 |
| `savingsHbdBalance`  | `Savings HBD`    | `Icons.savings_outlined`        |
| `hivePower`          | `Hive Power`     | `Icons.flash_on`                |

Each tile has a circle icon, label, and amount — all styled with the corresponding color props.

### Error Card (Optional)

If `wallet.error` is set:

- Displays a red alert card using `errorColor`.
- Includes error icon, title (`Error`), and detailed message.

---

## Loading & Error Handling

| State           | Behavior                                      |
|------------------|-----------------------------------------------|
| `loading`        | Shows circular progress indicator             |
| `error`          | Displays error card with retry suggestion     |
| `null response`  | Displays `No wallet data found` fallback text |

---

## Theme Handling

- Background uses a gradient between two `backgroundColors`.
- Defaults are chosen based on dark/light theme context.
- Font, card, and icon colors adapt to theme or custom settings.

---

## Dependencies

- `hive_flutter_kit` — for backend integration and wallet fetching
- `WalletData` model
- Flutter Material UI widgets

---
