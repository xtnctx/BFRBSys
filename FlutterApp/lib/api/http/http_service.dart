import 'package:bfrbsys/shared/shared.dart';

import '../env.dart';
import '../models.dart';

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'neural_network_request.dart';

class HttpService {
  /// [/] Register     - username, password, email     <POST>
  /// [/] Login        - username, password            <POST>
  /// [/] Logout       - Token                         <POST>
  /// [/] UserInfo     - Token                         <GET>

  Future<Logout> postLogout({required String userToken}) async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/api/auth/logout/"),
      headers: {'Authorization': 'Token $userToken'},
    );

    if (response.statusCode == 204) {
      return Logout.http204();
    } else {
      throw Exception(jsonDecode(response.body)['detail']);
    }
  }

  Future<Login> postLogin({required String username, required String password}) async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/api/auth/login/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return Login.fromJson(jsonDecode(response.body));
    } else {
      throw Login.onError(jsonDecode(response.body));
    }
  }

  Future<RegisterModel> postRegister({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/api/auth/register/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return RegisterModel.fromJson(jsonDecode(response.body));
    } else {
      throw RegisterModel.onError(jsonDecode(response.body));
    }
  }

  Future<UserInfo> getUserInfo({required String userToken}) async {
    final response = await http.get(
      Uri.parse("${Env.URL_PREFIX}/api/auth/user/"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $userToken',
      },
    );

    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<List<Item>> getItems() async {
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/api/"));
    final items = json.decode(response.body).cast<Map<String, dynamic>>();

    List<Item> employees = items.map<Item>((json) {
      return Item.fromJson(json);
    }).toList();

    return employees;
  }

  /// [fileEncoded] base64
  Future<TrainedModels> postModel({
    required String fileEncoded,
    required String modelName,
    required String userToken,
  }) async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/api/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $userToken',
      },
      body: jsonEncode(<String, String>{
        'file': fileEncoded,
        'model_name': modelName,
      }),
    );

    if (response.statusCode == 201) {
      return TrainedModels.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body));
    }
  }

  Future<TrainedModels> sendInput({
    required String filePath,
    required String modelName,
    required String userToken,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse("${Env.URL_PREFIX}/api/"))
      ..headers.addAll({"Authorization": "Token $userToken"})
      ..fields['model_name'] = modelName
      ..files.add(
        http.MultipartFile(
          'file',
          File(filePath).readAsBytes().asStream(),
          File(filePath).lengthSync(),
          filename: filePath.split("/").last,
        ),
      );
    http.Response response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 201) {
      return TrainedModels.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body));
    }
  }

  Future authenticate() async {
    var token = await UserSecureStorage.getToken();

    // ignore: unnecessary_null_comparison
    if (token == '') {
      return false; // then proceed the login page
    } else {
      final response = await http.get(
        Uri.parse("${Env.URL_PREFIX}/api/auth/user/"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      ).onError((error, _) {
        return http.Response(error.toString(), 408);
      });
      // .timeout(
      //   const Duration(seconds: 10),
      //   onTimeout: () {
      //     return http.Response('Connection timed out', 408);
      //   },
      // );

      return response;
    }
  }
}
