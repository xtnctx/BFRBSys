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

import 'package:bfrbsys/shared/shared.dart';
import 'package:flutter/foundation.dart';

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
      Uri.parse("${Env.BASE_URL}/api/auth/logout/"),
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
      Uri.parse("${Env.BASE_URL}/api/auth/login/"),
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
      Uri.parse("${Env.BASE_URL}/api/auth/register/"),
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
      Uri.parse("${Env.BASE_URL}/api/auth/user/"),
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
    final response = await http.get(Uri.parse("${Env.BASE_URL}/api/"));
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
      Uri.parse("${Env.BASE_URL}/api/"),
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
    var request = http.MultipartRequest('POST', Uri.parse("${Env.BASE_URL}/api/"))
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
    print('################## $token');

    // ignore: unnecessary_null_comparison
    if (token == '') {
      return false; // then proceed the login page
    } else {
      final response = await http.get(
        Uri.parse("${Env.BASE_URL}/api/auth/user/"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      ).onError((error, _) {
        return http.Response(error.toString(), 408);
      });

      // if (response.statusCode == 401) {
      //   return http.Response(response.body, response.statusCode);
      // } else if (response.statusCode == 401) {
      //   return http.Response(response.body, response.statusCode);
      // }
      // .timeout(
      //   const Duration(seconds: 10),
      //   onTimeout: () {
      //     return http.Response('Connection timed out', 408);
      //   },
      // );

      return response;
    }
  }

  Future<String> downloadFile(String fileUrl, String location) async {
    HttpClient httpClient = HttpClient();

    try {
      var request = await httpClient.getUrl(Uri.parse("${Env.BASE_URL}$fileUrl"));
      var response = await request.close();

      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        File file = await File(location).create(recursive: true);
        await file.writeAsBytes(bytes);
        return 'Prepairing data... ';
      } else {
        throw Exception('Error code: ${response.statusCode}');
      }
    } catch (_) {
      throw Exception('Can not fetch url');
    }
  }

  Future<String> downloadAllUserFiles({required String userToken, required String location}) async {
    HttpClient httpClient = HttpClient();

    try {
      final response = await http.get(
        Uri.parse("${Env.BASE_URL}/api/user-models/"),
        headers: {
          'Content-Type': 'application/x-zip-compressed; charset=UTF-8',
          'Authorization': 'Token $userToken',
        },
      );

      if (response.statusCode == 200) {
        File file = await File(location).create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        return 'Download complete. ';
      } else {
        throw Exception('Error code: ${response.statusCode}');
      }
    } catch (_) {
      throw Exception('Can not fetch url');
    }
  }
}
