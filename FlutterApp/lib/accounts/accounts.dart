import 'package:bfrbsys/api/http/http_service.dart';
import 'package:bfrbsys/api/models.dart';
import 'package:flutter/material.dart';
import 'package:bfrbsys/custom_widgets/tooltip.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bfrbsys/shared/shared.dart';

part 'login_page.dart';
part 'register_page.dart';

extension on String {
  String? isValidUsername() {
    bool startWithChar = RegExp(r'^[a-zA-Z]').hasMatch(this);
    bool isLen2 = RegExp(r'^.{2,}$').hasMatch(this);

    if (!startWithChar) return 'Must start with a letter';
    if (!isLen2) return 'Must be at least 2 characters in length';
    return null;
  }

  String? isValidEmail() {
    bool isValid = RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
    if (!isValid) return 'Invalid email';
    return null;
  }

  String? isValidPassword() {
    bool isLen8 = RegExp(r'^.{8,}$').hasMatch(this);
    bool containsUpper = RegExp(r'^(?=.*?[A-Z])').hasMatch(this);
    bool containsDigit = RegExp(r'^(?=.*?[0-9])').hasMatch(this);
    bool containsSpecialChar = RegExp(r'^(?=.*?[!@#\$&*~])').hasMatch(this);

    if (!isLen8) return 'Must be at least 8 characters in length';
    if (!containsUpper) return 'Should contain at least one upper case';
    if (!containsDigit) return 'Should contain at least one digit';
    if (!containsSpecialChar) return 'Should contain at least one special character';
    return null;
  }
}

class Accounts extends StatefulWidget {
  final String msg;
  const Accounts({super.key, required this.msg});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  int currentPage = 0;
  String msg = '';

  @override
  void initState() {
    msg = widget.msg;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: IndexedStack(
        index: currentPage,
        children: [
          LoginPage(
              msg: msg,
              onButtonPressed: () {
                setState(() {
                  currentPage = 1;
                });
              }),
          RegisterPage(onButtonPressed: () {
            setState(() {
              currentPage = 0;
            });
          }),
        ],
      ),
    ));
  }
}
