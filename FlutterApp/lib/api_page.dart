import 'dart:convert';
import 'package:bfrbsys/api/http_service.dart';
import 'package:bfrbsys/api/models/models.dart';
import 'package:flutter/material.dart';

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

  late String userToken;

  @override
  void initState() {
    super.initState();
    // _items = httpService.getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: logoutWidget());
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

  Container postWidget() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: (_futureModels == null) ? buildColumn() : buildFutureBuilder(),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter Title'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _futureModels = httpService.postModel(_controller.text);
            });
          },
          child: const Text('Create Data'),
        ),
      ],
    );
  }

  FutureBuilder<TrainedModels> buildFutureBuilder() {
    return FutureBuilder<TrainedModels>(
      future: _futureModels,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.modelName);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
