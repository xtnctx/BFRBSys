part of 'page_handler.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'BFRBSys',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(fontSize: 50),
                ),
                subtitle: Text(
                  'A wrist-worn device and monitoring system for a person with Body-focused Repetitive Behavior',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
                onPressed: () {
                  Provider.of<ConnectionProvider>(context, listen: false).toggle(true);
                },
                child: const Text('Connect')),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
