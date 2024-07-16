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

part of 'page_manager.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.secondaryContainer,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('images/ekusuuuu-calibaaaaaaaaaaaaa.png'),
              radius: 80,
            ),
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
            const SizedBox(height: 150),

            // // From logout API
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              ),
              onPressed: () {
                _futureLogout = httpService.postLogout(userToken: token ?? '');

                _futureLogout!.then((value) {
                  if (value.http204Message != null) {
                    Navigator.popAndPushNamed(context, '/accounts');
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
