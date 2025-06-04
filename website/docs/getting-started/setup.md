---
sidebar_position: 1
title: Setup
sidebar_label: Setup
---

# Setup for Android, iOS, and Web

First, add the necessary dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  aioha_flutter_core: ^latest_version # Replace with the actual latest version
  provider: ^latest_provider_version # Replace if you use provider
```

Then, run `flutter pub get`.

## Main Application Setup

Update your `main.dart` function as follows to make the Aioha instance available via Provider (or your preferred state management solution):

```dart
import 'package:flutter/material.dart';
import 'package:aioha_flutter_core/aioha_flutter_core.dart'; // Ensure correct import
import 'package:provider/provider.dart'; // If using Provider

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    Provider<AiohaFlutterCorePlatform>.value(
      value: AiohaFlutterCorePlatform.instance,
      child: const MyApp(), // Your main application widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIOHA Flutter Core Demo',
      home: MyHomePage(), // Your home page
    );
  }
}
// ... rest of your MyApp or MyHomePage implementation
```

### Extra Setup for Using AIOHA Flutter Core in a Web App

If you are targeting web, open your `web/index.html` file and add the following script tag to the `<body>` section, before the Flutter bootstrap script:

```html
<body>
  <!-- Add this line -->
  <script src="packages/aioha_flutter_core/web/aioha.js" type="application/javascript" defer></script>

  <script src="flutter_bootstrap.js" async></script>
</body>
```
