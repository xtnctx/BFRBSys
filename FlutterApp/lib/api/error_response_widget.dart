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
