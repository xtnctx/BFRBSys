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

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:google_fonts/google_fonts.dart';

class ResponseCodeWidget extends StatelessWidget {
  const ResponseCodeWidget({super.key, required this.response});
  final Response response;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              response.statusCode.toString(),
              style: GoogleFonts.bebasNeue(fontSize: 70),
            ),
            Text(
              '${response.body}, try again later.',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
