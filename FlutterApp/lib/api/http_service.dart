import 'package:bfrbsys/api/env.dart';
import 'package:bfrbsys/api/models/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpService {
  Future<List<Item>> get() async {
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/api"));
    final items = json.decode(response.body).cast<Map<String, dynamic>>();

    List<Item> employees = items.map<Item>((json) {
      return Item.fromJson(json);
    }).toList();

    return employees;
  }

  Future<TrainedModels> post(String modelName) async {
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
