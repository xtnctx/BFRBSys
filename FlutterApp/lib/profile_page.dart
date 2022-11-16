import 'package:bfrbsys/api/http_service.dart';
import 'package:bfrbsys/api/models/models.dart';
import 'package:bfrbsys/device_storage.dart';
import 'package:bfrbsys/login_page.dart';
import 'package:bfrbsys/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.person_outlined);
  final Icon navBarIconSelected = const Icon(Icons.person);
  final String navBarTitle = 'Profile';
  final PageController pageController;
  const ProfilePage({super.key, required this.pageController});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? email;
  String? token;

  HttpService httpService = HttpService();
  Future<Logout>? _futureLogout;

  @override
  void initState() {
    super.initState();
    getUserInfoFromStorage();
  }

  void getUserInfoFromStorage() async {
    var user = await UserSecureStorage.getUser();
    var userToken = await UserSecureStorage.getToken();
    setState(() {
      username = user['username'];
      email = user['email'];
      token = userToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              username ?? 'loading...',
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(fontSize: 50),
            ),
            Text(
              email ?? 'loading...',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(fontSize: 18),
            ),
            const SizedBox(height: 50),

            // From logout API
            // FutureBuilder<Logout>(
            //   future: _futureLogout,
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return Column(
            //         children: [
            //           Text(snapshot.data!.http204Message ?? ""),
            //         ],
            //       );
            //     } else if (snapshot.hasError) {
            //       return Text('${snapshot.error}');
            //     }

            //     // By default, show a loading spinner.
            //     return const CircularProgressIndicator();
            //   },
            // ),
            ElevatedButton(
              onPressed: () {
                _futureLogout = httpService.postLogout(userToken: token ?? '');

                _futureLogout!.then((value) {
                  if (value.http204Message != null) {
                    currentPage = 0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  }
                });
              },
              child: const Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}
