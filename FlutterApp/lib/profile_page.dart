import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.person_outlined);
  final Icon navBarIconSelected = const Icon(Icons.person);
  final String navBarTitle = 'Profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int itemCount = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('Item ${index + 1}'),
            leading: const Icon(Icons.person),
            trailing: const Icon(Icons.flash_on),
            onTap: () {
              debugPrint('Item ${index + 1} selected');
            },
          );
        },
      ),
    );
  }
}
