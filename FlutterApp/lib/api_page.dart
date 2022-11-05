import 'dart:convert';
import 'package:bfrbsys/api/http_service.dart';
import 'package:bfrbsys/api/model/item.dart';
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

  @override
  void initState() {
    super.initState();
    _items = httpService.get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
      ),
    );
  }
}
