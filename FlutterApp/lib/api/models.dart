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

class Item {
  final int id;
  final String name;

  Item({required this.id, required this.name});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class TrainedModels {
  final int id;
  final String modelName;
  final String createdAt;
  final String updatedAt;
  final String file;
  final String callbackFile;
  final int owner;

  TrainedModels({
    required this.id,
    required this.modelName,
    required this.createdAt,
    required this.updatedAt,
    required this.file,
    required this.callbackFile,
    required this.owner,
  });

  factory TrainedModels.fromJson(Map<String, dynamic> json) {
    return TrainedModels(
      id: json['id'],
      modelName: json['model_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      file: json['file'],
      callbackFile: json['callback_file'],
      owner: json['owner'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model_name': modelName,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'file': file,
        'callback_file': callbackFile,
        'owner': owner,
      };
}

// GET
class UserInfo {
  final int id;
  final String username;
  final String email;

  UserInfo({required this.id, required this.username, required this.email});

  factory UserInfo.fromJson(Map<String, dynamic> data) => UserInfo(
        id: data['id'],
        username: data['username'],
        email: data['email'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
      };
}

// POST
class RegisterModel {
  final Map<String, dynamic> user; // contains id, username, email
  final String token;
  final Map<String, dynamic>? errorMsg;

  RegisterModel({required this.user, required this.token, this.errorMsg});

  factory RegisterModel.fromJson(Map<String, dynamic> data) => RegisterModel(
        user: data['user'],
        token: data['token'],
      );

  factory RegisterModel.onError(Map<String, dynamic>? data) => RegisterModel(
        errorMsg: data,
        token: '',
        user: {},
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "token": token,
      };
}

// POST
class Login {
  final Map<String, dynamic> user; // contains id, username, email
  final String token;
  final Map<String, dynamic>? errorMsg;

  Login({required this.user, required this.token, this.errorMsg});

  factory Login.fromJson(Map<String, dynamic> data) => Login(
        user: data['user'],
        token: data['token'],
      );

  factory Login.onError(Map<String, dynamic>? data) => Login(
        errorMsg: data,
        token: '',
        user: {},
      );

  Map<String, dynamic> get toJson => {
        "user": user,
        "token": token,
      };
}

// POST
class Logout {
  String? http204Message;
  Logout({this.http204Message});

  factory Logout.http204() => Logout(http204Message: 'Logout success.');
}
