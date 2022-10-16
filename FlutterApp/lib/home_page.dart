import 'package:bfrbsys/ble_connection.dart';
import 'package:flutter/material.dart';

class HomePapge extends StatelessWidget {
  const HomePapge({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
        child: const Text('Connect'),
      ),
    );
  }
}
