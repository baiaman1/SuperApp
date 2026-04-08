import 'package:flutter/foundation.dart';

final class AppEnvironment {
  const AppEnvironment._();

  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5078';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:5078',
      _ => 'http://127.0.0.1:5078',
    };
  }

  static String get deviceName {
    if (kIsWeb) {
      return 'flutter-web';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android-emulator',
      TargetPlatform.iOS => 'ios-simulator',
      TargetPlatform.windows => 'windows-desktop',
      TargetPlatform.macOS => 'macos-desktop',
      TargetPlatform.linux => 'linux-desktop',
      TargetPlatform.fuchsia => 'flutter-device',
    };
  }
}
