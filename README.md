# Local Config

> 🧩 A Flutter package for managing **local configs** — just like Remote Config, but offline.

---

## ✨ Features

- Manage app configuration values locally  
- Use a familiar API inspired by **Firebase Remote Config**  
- Easily initialize from a simple `Map`.
- Access configs at runtime anywhere in your app  
- Built-in entrypoint screen for viewing/editing local configs  

---

## 🚀 Getting Started

#### Add dependency

```yaml
dependencies:
  local_config: ^0.0.2
```

#### Initialize with your parameters

```dart
import 'package:flutter/material.dart';
import 'package:local_config/local_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalConfig.instance.initialize(
    defaults: {
        'feature_enabled': 'true',
        'api_base_url': 'https://api.myapp.com/v1',
        'retry_attempts': '3',
        'animation_speed': '1.25',
        'theme': '{"seedColor": "#2196F3", "darkMode": false}',
    },
  );

  runApp(const YourApp());
}
```

#### Or with the `FirebaseRemoteConfig` parameters

```dart
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:local_config/local_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseRemoteConfig.instance.fetchAndActivate();

  await LocalConfig.instance.initialize(
    defaults: FirebaseRemoteConfig.instance.getAll().map(
      (key, value) => MapEntry(key, value.asString()),
    ),
  );

  runApp(const YourApp());
}
```

#### Navigate to entrypoint widget

```dart
FilledButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocalConfigEntrypoint(),
      ),
    );
  },
  child: const Text('Local Config'),
)
```

#### Get parameter values

```dart
final featureEnabled = LocalConfig.instance.getBool('feature_enabled');
final apiBaseUrl = LocalConfig.instance.getString('api_base_url');
final retryAttempts = LocalConfig.instance.getInt('retry_attempts');
final animatinoSpeed = LocalConfig.instance.getDouble('animation_speed');
final theme = LocalConfig.instance.getString('theme');
```

#### Or listen for updates in real time

```dart
LocalConfig.instance.onConfigUpdated.listen((configs) {
  print('Configs updated: $configs');
});
```

For a full demo, check the [`example`](https://github.com/adrianotelesc/local-config/tree/main/example) folder.

---

## 🧠 Why Local Config?

Use this package when you:
- Want to replicate Remote Config behavior **without needing a backend**  
- Need **local overrides** for testing or staging  
- Prefer to keep configuration values bundled with the app  

---

## 📦 Additional Information

- 🐛 Report issues or request features in the [GitHub Issues](https://github.com/yourusername/local_config/issues)  
- 💬 Contributions are welcome! Feel free to open pull requests.  
- 🧾 Licensed under MIT  
