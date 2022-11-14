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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class TrainedModels {
  final int id;
  final String modelName;

  TrainedModels({required this.id, required this.modelName});

  factory TrainedModels.fromJson(Map<String, dynamic> json) {
    return TrainedModels(
      id: json['id'],
      modelName: json['model_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model_name': modelName,
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

  RegisterModel({required this.user, required this.token});

  factory RegisterModel.fromJson(Map<String, dynamic> data) => RegisterModel(
        user: data['user'],
        token: data['token'],
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

  Login({required this.user, required this.token});

  factory Login.fromJson(Map<String, dynamic> data) => Login(
        user: data['user'],
        token: data['token'],
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
