import 'package:flutter/material.dart';

class ConnectionProvider extends ChangeNotifier {
  bool _value = false;

  set setConnected(bool value) {
    _value = value;
    notifyListeners();
  }

  bool get isConnected => _value;
}
