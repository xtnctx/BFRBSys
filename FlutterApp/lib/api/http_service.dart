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
      headers: {'Authorization': 'Token $userToken'},
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
      headers: {'Authorization': 'Token $userToken'},
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

  Future<TrainedModels> postModel(String modelName) async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/api/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'model_name': modelName,
      }),
    );

    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return TrainedModels.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create model.');
    }
  }
}
