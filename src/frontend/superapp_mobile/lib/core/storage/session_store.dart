import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp_mobile/core/models/app_models.dart';

class SessionStore {
  SessionStore(this._preferences);

  static const _sessionKey = 'superapp_mobile.auth_session.v1';

  final SharedPreferences _preferences;

  Future<AuthSession?> read() async {
    final raw = _preferences.getString(_sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final payload = jsonDecode(raw) as Map<String, dynamic>;
    return AuthSession.fromJson(payload);
  }

  Future<void> write(AuthSession session) {
    return _preferences.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clear() {
    return _preferences.remove(_sessionKey);
  }
}
