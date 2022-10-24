import 'package:bfrbsys/ble_connection.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final Icon navBarIcon = const Icon(Icons.home_outlined);
  final Icon navBarIconSelected = const Icon(Icons.home);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const BluetoothBuilderPage();
                },
              ),
            );
          },
          child: const Text('Start'),
        ),
      ),
    );
  }
}
