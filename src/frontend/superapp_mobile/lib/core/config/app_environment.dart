import 'package:flutter/foundation.dart';

final class AppEnvironment {
  const AppEnvironment._();

  static String get apiBaseUrl {
    // 👉 теперь везде используем прод сервер
    return 'http://13.220.53.240';
  }

  static String get deviceName {
    if (kIsWeb) {
      return 'flutter-web';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android-device',
      TargetPlatform.iOS => 'ios-device',
      TargetPlatform.windows => 'windows-desktop',
      TargetPlatform.macOS => 'macos-desktop',
      TargetPlatform.linux => 'linux-desktop',
      TargetPlatform.fuchsia => 'flutter-device',
    };
  }
}