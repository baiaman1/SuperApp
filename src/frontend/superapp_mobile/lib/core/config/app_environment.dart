import 'package:flutter/foundation.dart';

final class AppEnvironment {
  const AppEnvironment._();

  static const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_configuredApiBaseUrl.isNotEmpty) {
      return _configuredApiBaseUrl;
    }

    return 'http://13.220.53.240:5000';
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
