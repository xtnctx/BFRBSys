import 'package:bfrbsys/main.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.home_outlined);
  final Icon navBarIconSelected = const Icon(Icons.home);
  final String navBarTitle = 'Home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('This home page, will populate this in future.'),
        ),
      ),
    );
  }
}
