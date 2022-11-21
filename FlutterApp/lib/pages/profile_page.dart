part of 'page_handler.dart';

class ProfilePage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.person_outlined);
  final Icon navBarIconSelected = const Icon(Icons.person);
  final String navBarTitle = 'Profile';
  const ProfilePage({super.key});

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
              style: const TextStyle(fontSize: 18),
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
                    Navigator.popAndPushNamed(context, '/login');
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
