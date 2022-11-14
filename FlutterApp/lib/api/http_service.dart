import 'dart:io';

import 'package:bfrbsys/api/env.dart';
import 'package:bfrbsys/api/models/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpService {
  /// [/] Register     - username, password, email     <POST>
  /// [/] Login        - username, password            <POST>
  /// [/] Logout       - Token                         <POST>
  /// [/] UserInfo     - Token                         <GET>

  Future<Logout> postLogout({required String userToken}) async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/api/auth/logout/"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $userToken',
      },
    );

    if (response.statusCode == 204) {
      return Logout.http204();
    } else {
      throw Exception(jsonDecode(response.body)['detail']);
    }
  }

  Future<Login> postLogin({
    required String username,
    required String password,
  }) async {
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
      throw Exception('Failed to login user');
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
      throw Exception('Failed to register user');
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
}
