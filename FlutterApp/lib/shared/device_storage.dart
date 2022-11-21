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

class AppStorage {
  static Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<void> generateCSV({required List<List<String>> data, required String fileName}) async {
    String directory = await localPath();
    File file = File("$directory/$fileName.csv");

    String csvData = const ListToCsvConverter().convert(data);
    await file.writeAsString(csvData);
  }

  static Future<String> fileToBase64Encoded({required String fileName}) async {
    try {
      String directory = await localPath();
      File file = File("$directory/$fileName");
      return base64Encode(file.readAsBytesSync());
    } catch (e) {
      return '$e';
    }
  }
}
