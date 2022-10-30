import 'package:flutter/material.dart';

class ResultsPage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.fact_check_outlined);
  final Icon navBarIconSelected = const Icon(Icons.fact_check);
  final String navBarTitle = 'Results';

  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 200, // card height
          child: PageView.builder(
            itemCount: 3,
            controller: PageController(viewportFraction: 0.7),
            onPageChanged: (int index) => setState(() => _index = index),
            itemBuilder: (_, i) {
              return Transform.scale(
                scale: i == _index ? 1 : 0.9,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      "Card ${i + 1}",
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
