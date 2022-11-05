import 'package:bfrbsys/api/env.dart';
import 'package:bfrbsys/api/model/item.dart';
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
}
