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
  final int owner;

  TrainedModels({
    required this.id,
    required this.modelName,
    required this.createdAt,
    required this.updatedAt,
    required this.file,
    required this.owner,
  });

  factory TrainedModels.fromJson(Map<String, dynamic> json) {
    return TrainedModels(
      id: json['id'],
      modelName: json['model_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      file: json['file'],
      owner: json['owner'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model_name': modelName,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'file': file,
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
