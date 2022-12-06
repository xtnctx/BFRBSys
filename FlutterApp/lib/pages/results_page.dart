part of 'page_handler.dart';

class ResultsPage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.fact_check_outlined);
  final Icon navBarIconSelected = const Icon(Icons.fact_check);
  final String navBarTitle = 'Results';

  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  String? dir;
  List<io.FileSystemEntity> dataFile = [];
  List<String> modelItems = [];
  String selectedModel = '';

  List<String> historyList = <String>['Accuracy', 'Loss'];
  late String dropdownValue;
  bool chartVisibility = true;
  bool transferWidgetVisibility = true;
  int _selectedIndex = 0;

  _getListofData() async {
    dir = await AppStorage.getDir();
    setState(() {
      dataFile = io.Directory(dir!).listSync();
      for (var item in dataFile) {
        modelItems.add(item.path.split('/').last);
      }
      selectedModel = modelItems[_selectedIndex];
    });
  }

  @override
  void initState() {
    super.initState();
    _getListofData();
    dropdownValue = historyList.first;
  }

  void doNothing(BuildContext context) {}
  @override
  Widget build(BuildContext context) {
    final List<ChartData> trainingData = [
      ChartData(1, 0.08),
      ChartData(2, 0.3),
      ChartData(3, 0.4),
      ChartData(4, 0.36),
      ChartData(5, 0.39),
      ChartData(6, 0.52),
      ChartData(7, 0.63),
      ChartData(8, 0.68),
      ChartData(9, 0.85),
      ChartData(10, 0.9),
    ];
    final List<ChartData> validationData = [
      ChartData(1, 0.1),
      ChartData(2, 0.23),
      ChartData(3, 0.15),
      ChartData(4, 0.3),
      ChartData(5, 0.4),
      ChartData(6, 0.35),
      ChartData(7, 0.42),
      ChartData(8, 0.5),
      ChartData(9, 0.8),
      ChartData(10, 0.85),
    ];
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Trained Model',
                textAlign: TextAlign.left,
                style: GoogleFonts.bebasNeue(fontSize: 30),
              ),
              subtitle: Text(
                selectedModel,
                textAlign: TextAlign.left,
                style: GoogleFonts.bebasNeue(fontSize: 18),
              ),
              trailing: IconButton(
                iconSize: 30,
                onPressed: () {
                  setState(() {
                    chartVisibility = !chartVisibility;
                  });
                },
                icon: Icon(!chartVisibility ? Icons.arrow_drop_down : Icons.arrow_drop_up),
              ),
            ),
          ),
          Visibility(
            visible: chartVisibility,
            child: SizedBox(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Container(
                          color: Theme.of(context).colorScheme.primary,
                          child: Container(
                            margin: const EdgeInsets.only(left: 20, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DropdownButton(
                                  value: dropdownValue,
                                  underline: Container(height: 0),
                                  items: historyList.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    // This is called when the user selects an item.
                                    setState(() {
                                      dropdownValue = value!;
                                    });
                                  },
                                ),
                                // Legends
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Wrap(
                                      children: const [
                                        Icon(
                                          Icons.horizontal_rule_rounded,
                                          color: CustomColor.trainingLineColor,
                                        ),
                                        Text('training'),
                                      ],
                                    ),
                                    Wrap(
                                      children: const [
                                        Icon(
                                          Icons.horizontal_rule_rounded,
                                          color: CustomColor.validationLineColor,
                                        ),
                                        Text('validation'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 210,
                        // width: width,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          child: SfCartesianChart(
                            title: ChartTitle(
                              text: 'Model history',
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.inverseSurface.withAlpha(125),
                              ),
                            ),
                            // plotAreaBorderWidth: 0,
                            primaryXAxis: NumericAxis(
                              title: AxisTitle(text: 'Epoch', textStyle: const TextStyle(fontSize: 12)),
                            ),
                            primaryYAxis: NumericAxis(
                              minimum: 0.0,
                              maximum: 1.0,
                              title: AxisTitle(text: 'Accuracy', textStyle: const TextStyle(fontSize: 12)),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            series: <ChartSeries>[
                              // Renders line chart
                              LineSeries<ChartData, int>(
                                  dataSource: trainingData,
                                  color: CustomColor.trainingLineColor,
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) => data.y),
                              LineSeries<ChartData, int>(
                                  dataSource: validationData,
                                  color: CustomColor.validationLineColor,
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) => data.y),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Transfer',
                textAlign: TextAlign.left,
                style: GoogleFonts.bebasNeue(fontSize: 20),
              ),
              trailing: IconButton(
                iconSize: 30,
                onPressed: () {
                  setState(() {
                    transferWidgetVisibility = !transferWidgetVisibility;
                  });
                },
                icon: Icon(!transferWidgetVisibility ? Icons.arrow_drop_down : Icons.arrow_drop_up),
              ),
            ),
          ),
          Visibility(
            visible: transferWidgetVisibility,
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Status
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Row(
                    children: const [
                      Text('Sending... 70%'),
                    ],
                  ),
                ),
                // Progress bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: const SizedBox(
                    height: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: LinearProgressIndicator(
                        value: 0.7,
                      ),
                    ),
                  ),
                ),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        onPressed: () {
                          print(dataFile[0].path);
                        },
                        icon: const Icon(Icons.cancel)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Divider(),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Models',
              textAlign: TextAlign.left,
              style: GoogleFonts.bebasNeue(fontSize: 20),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              itemCount: modelItems.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Text(modelItems[index]),
                    tileColor:
                        index == _selectedIndex ? Theme.of(context).colorScheme.tertiaryContainer : null,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                        selectedModel = modelItems[index];
                      });
                    },
                    leading: CircleAvatar(child: Text(modelItems[index][0])),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        // PopupMenuItem 1ss
                        const PopupMenuItem(value: 1, child: Text('View size')),
                        PopupMenuItem(value: 2, onTap: _deleteModel, child: const Text('Delete')),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _deleteModel() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete __?'),
            content: const Text('Are you sure you want to delete?'),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Delete"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double y;
}
