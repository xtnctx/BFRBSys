import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyUser = 'user';
  static const _keyToken = 'token';

  static Future getUser() async => await _storage.read(key: _keyUser);

  static Future setUser({required Map<String, dynamic> user}) async {
    String value = json.encode(user);
    await _storage.write(key: _keyUser, value: value);
  }

  static Future getToken() async => await _storage.read(key: _keyToken);

  static Future setToken({required String token}) async {
    String value = json.encode(token);
    await _storage.write(key: _keyToken, value: value);
  }
}
