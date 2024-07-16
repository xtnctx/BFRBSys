/* Copyright 2024 Ryan Christopher Bahillo. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=========================================================================*/

part of 'shared.dart';

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyUser = 'user';
  static const _keyToken = 'token';

  static Future<Map<String, dynamic>> getUser() async {
    var value = await _storage.read(key: _keyUser);
    if (value != null) {
      Map<String, dynamic> user = json.decode(value);
      return user;
    }
    return {};
  }

  static Future setUser({required Map<String, dynamic> user}) async {
    String value = json.encode(user);
    await _storage.write(key: _keyUser, value: value);
  }

  static Future<String> getToken() async {
    var value = await _storage.read(key: _keyToken);
    if (value != null) {
      String token = json.decode(value);
      return token;
    }
    return '';
  }

  static Future setToken({required String token}) async {
    String value = json.encode(token);
    await _storage.write(key: _keyToken, value: value);
  }
}

/// === TREE ===
/// ```
/// /ApplicationDocumentsDirectory
///     |
///     --> /data
///             |
///             --> /user.username
/// ```
class AppStorage {
  static Future<String> getDir() async {
    String applicationDocumentsDirectory = await localPath();
    var user = await UserSecureStorage.getUser();
    String username = user['username'];
    return "$applicationDocumentsDirectory/data/$username";
  }

  static Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<void> mkdir() async {
    String dir = await getDir();
    await Directory(dir).create(recursive: true);
  }

  static Future<void> writeCsv({required List<List<String>> data, required String filePath}) async {
    File file = await File(filePath).create(recursive: true);
    String csvData = const ListToCsvConverter().convert(data);
    await file.writeAsString(csvData);
  }

  static Future<void> writeJson({required Map<String, dynamic> data, required String filePath}) async {
    File file = await File(filePath).create(recursive: true);
    await file.writeAsString(json.encode(data));
  }

  static Future<String> fileToBase64Encoded({required String filePath}) async {
    try {
      File file = File(filePath);
      return base64Encode(file.readAsBytesSync());
    } catch (e) {
      return '$e';
    }
  }
}
