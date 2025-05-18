# Aioha

## All-In-One Hive Authentication

### Introduction

- Aioha (All-In-One Hive Authentication) is an API that provides a common interface for working with different Hive login providers. 
- This allows easier integration of Hive login and transacting on the network with fewer code.
- For Javascript package usage, https://aioha.dev/docs

### AIOHA Flutter Core

- Aioha Flutter Core is a Flutter package that provides a common interface for working with different Hive login providers.
- This allows easier integration of Hive login and transacting on the network with fewer code.
- For Flutter package usage, https://pub.dev/packages/aioha
- For more information about the Aioha API, please visit the [Aioha API documentation](https://aioha.dev/docs).
- For more information about the Aioha Flutter Core, please visit the [Aioha Flutter Core documentation](https://pub.dev/packages/aioha).

## Setup for Android, iOS, and Web

```
flutter pub add provider
```

Update main function as follows:

```dart
import 'package:aioha_flutter_core/aioha_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    Provider<AiohaFlutterCorePlatform>.value(
      value: AiohaFlutterCorePlatform.instance,
      child: const MyApp(),
    ),
  );
}
```

### Extra Setup for Using AIOHA Flutter Core in web-app

Open web/index.html and add the following script tag to the body section:

```html
<body>
  <script src="flutter_bootstrap.js" async></script>
  <script src="packages/aioha_flutter_core/web/aioha.js" type="application/javascript" defer></script>
  <script src="packages/aioha_flutter_core/web/196.aioha.js" type="application/javascript" defer></script>
  <script src="packages/aioha_flutter_core/web/769.aioha.js" type="application/javascript" defer></script>
  <script src="packages/aioha_flutter_core/web/785.aioha.js" type="application/javascript" defer></script>
</body>
```

### Usage Guide

```dart
import 'package:aioha_flutter_core/aioha_core.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AiohaFlutterCorePlatform aioha;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    aioha = Provider.of<AiohaFlutterCorePlatform>(context, listen: false);
  }

  void _loginWithHiveKeychain() async {
    try {
      // following line uses aioha
      final result = await aioha.plugin.loginWithKeychain(
        _usernameController.text,
        'some-text-to-be-signed', // if we send empty string, it will be auto-generated
      );
    } catch (e) {

    }
  }
}
```