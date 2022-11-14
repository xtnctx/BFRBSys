import 'dart:convert';
import 'dart:io';
import 'package:bfrbsys/api/http_service.dart';
import 'package:bfrbsys/api/models/models.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class ApiService extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.api_outlined);
  final Icon navBarIconSelected = const Icon(Icons.api);
  final String navBarTitle = 'REST API';

  const ApiService({super.key});

  @override
  State<ApiService> createState() => _ApiServiceState();
}

class _ApiServiceState extends State<ApiService> {
  HttpService httpService = HttpService();
  Future<List<Item>>? _items;

  final TextEditingController _controller = TextEditingController();
  Future<TrainedModels>? _futureModels;

  Future<UserInfo>? _futureUserInfo;
  Future<RegisterModel>? _futureRegister;
  Future<Login>? _futureLogin;

  Future<Logout>? _futureLogout;

  @override
  void initState() {
    super.initState();
    // _items = httpService.getItems();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: csvWidget());
  }

  csvWidget() {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              generateCsv();
            },
            child: const Text('Generate CSV'),
          ),
          ElevatedButton(
            onPressed: () {
              readCsv();
            },
            child: const Text('Read CSV'),
          ),
        ],
      ),
    );
  }

  generateCsv() async {
    List<List<String>> data = [
      ["No.", "Name", "Roll No."],
      ["1", 'Ryan', '23'],
      ["2", 'Christopher', '45'],
      ["3", 'Bahillo', '67']
    ];
    String csvData = const ListToCsvConverter().convert(data);
    final String directory = await _localPath;
    final path = "$directory/data.csv";
    print(path);
    final File file = File(path);
    await file.writeAsString(csvData);
  }

  readCsv() async {
    try {
      final String directory = await _localPath;
      final path = "$directory/data.csv";
      final File file = File(path);
      // Read the file
      final contents = await file.readAsString();
      print(contents);
    } catch (e) {
      // If encountering an error, return 0
      print(e);
    }
  }

  logoutWidget() {
    return Center(
      child: Column(
        children: [
          FutureBuilder<Logout>(
            future: _futureLogout,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text(snapshot.data!.http204Message ?? ""),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _futureLogout = httpService.postLogout(
                      userToken: '1ce375b6cfe2f85c8e7c76a3b08b47d99b01ef9e4767818e13298fbc09b96da5');
                });
              },
              child: const Text('Logout')),
          ElevatedButton(
              onPressed: () {
                _futureLogout?.then((value) => debugPrint('${value.http204Message}'));
                print('hello');
              },
              child: const Text('print token'))
        ],
      ),
    );
  }

  // 3befa2b12befecb421496daeeea4221fbcdfacdcf48b78dc5b81a1705a7aa9f2

  postModelWidget() {
    return Center(
      child: Column(
        children: [
          FutureBuilder<TrainedModels>(
            future: _futureModels,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text(snapshot.data!.id.toString()),
                    Text(snapshot.data!.modelName),
                    Text(snapshot.data!.createdAt),
                    Text(snapshot.data!.updatedAt),
                    Text(snapshot.data!.file),
                    Text(snapshot.data!.owner.toString()),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _futureModels = httpService.postModel(
                    fileEncoded: '77u/Q29sMSxDb2wyLENvbDMNCjEsNCw3DQoyLDUsOA0KMyw2LDkNCg==',
                    modelName: 'dummyModel123',
                    userToken: '3befa2b12befecb421496daeeea4221fbcdfacdcf48b78dc5b81a1705a7aa9f2',
                  );
                });
              },
              child: const Text('Create model'))
        ],
      ),
    );
  }

  loginWidget() {
    return Center(
      child: Column(
        children: [
          FutureBuilder<Login>(
            future: _futureLogin,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text(snapshot.data!.user['id'].toString()),
                    Text(snapshot.data!.user['username']),
                    Text(snapshot.data!.user['email']),
                    Text(snapshot.data!.token),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _futureLogin = httpService.postLogin(username: 'dummy6', password: 'dummy6');
                });
              },
              child: const Text('Login')),
          ElevatedButton(
              onPressed: () {
                _futureLogin?.then((value) => debugPrint('${value.toJson}'));
                print('hello');
              },
              child: const Text('print token'))
        ],
      ),
    );
  }

  registrationWidget() {
    return Center(
      child: Column(
        children: [
          FutureBuilder<RegisterModel>(
            future: _futureRegister,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text(snapshot.data!.user['id'].toString()),
                    Text(snapshot.data!.user['username']),
                    Text(snapshot.data!.user['email']),
                    Text(snapshot.data!.token),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _futureRegister = httpService.postRegister(
                      username: 'dummy14', password: 'dummy14', email: 'dummy14email@gmail.com');
                });
              },
              child: const Text('Register user')),
          ElevatedButton(
              onPressed: () {
                _futureRegister?.then((value) => debugPrint('${value.toJson}'));
                print('hello');
              },
              child: const Text('print token'))
        ],
      ),
    );
  }

  getUserInfoWidget() {
    return Center(
        child: Column(
      children: [
        FutureBuilder<UserInfo>(
          future: _futureUserInfo,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Text(snapshot.data!.username),
                  Text(snapshot.data!.email),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {
                _futureUserInfo = httpService.getUserInfo(
                    userToken: '70a5995595c35246b312dde62641da77103db808819a7037d6ec5f7414279800');
              });
            },
            child: const Text('Get user info'))
      ],
    ));
  }

  Center getWidget() {
    return Center(
      child: FutureBuilder<List<Item>>(
        future: _items,
        builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
          // By default, show a loading spinner.
          if (!snapshot.hasData) return const CircularProgressIndicator();

          // if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          // switch (snapshot.connectionState) {
          //   case ConnectionState.none:
          //     return Text('Select lot');
          //   case ConnectionState.waiting:
          //     return Text('Awaiting bids...');
          //   case ConnectionState.active:
          //     return Text('\$${snapshot.data}');
          //   case ConnectionState.done:
          //     return Text('\$${snapshot.data} (closed)');
          // }
          // Render employee lists
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (BuildContext context, int index) {
              var data = snapshot.data![index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    data.name,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Container postWidget() {
  //   return Container(
  //     alignment: Alignment.center,
  //     padding: const EdgeInsets.all(8.0),
  //     child: (_futureModels == null) ? buildColumn() : buildFutureBuilder(),
  //   );
  // }

  // Column buildColumn() {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       TextField(
  //         controller: _controller,
  //         decoration: const InputDecoration(hintText: 'Enter Title'),
  //       ),
  //       ElevatedButton(
  //         onPressed: () {
  //           setState(() {
  //             _futureModels = httpService.postModel(_controller.text);
  //           });
  //         },
  //         child: const Text('Create Data'),
  //       ),
  //     ],
  //   );
  // }

  // FutureBuilder<TrainedModels> buildFutureBuilder() {
  //   return FutureBuilder<TrainedModels>(
  //     future: _futureModels,
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         return Text(snapshot.data!.modelName);
  //       } else if (snapshot.hasError) {
  //         return Text('${snapshot.error}');
  //       }

  //       return const CircularProgressIndicator();
  //     },
  //   );
  // }
}
