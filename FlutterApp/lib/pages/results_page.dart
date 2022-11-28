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
  List dataFile = [];
  List<String> historyList = <String>['Accuracy', 'Loss'];
  late String dropdownValue;

  @override
  void initState() {
    _listofData();
    dropdownValue = historyList.first;
    super.initState();
  }

  void _listofData() async {
    String localPath = await AppStorage.localPath();
    var user = await UserSecureStorage.getUser();
    setState(() {
      // dataFile = io.Directory("$localPath/${user['username']}/data/").listSync();
      dataFile = io.Directory("$localPath/").listSync();
    });
  }

  bool transferWidgetVisibility = false;

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
                'my-model-name',
                textAlign: TextAlign.left,
                style: GoogleFonts.bebasNeue(fontSize: 18),
              ),
            ),
          ),
          SizedBox(
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
          const SizedBox(height: 5),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Transfer',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.bebasNeue(fontSize: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: IconButton(
                  iconSize: 30,
                  onPressed: () {
                    setState(() {
                      transferWidgetVisibility = !transferWidgetVisibility;
                    });
                  },
                  icon: Icon(!transferWidgetVisibility ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                ),
              ),
            ],
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
                    height: 20,
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
                    IconButton(onPressed: () {}, icon: const Icon(Icons.cancel)),
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
          Expanded(
            child: ListView.builder(
              itemCount: dataFile.length,
              itemBuilder: (BuildContext context, int index) {
                return TextButton(
                    onPressed: () {
                      print(dataFile[index].toString().split('/').last);
                    },
                    child: Text(dataFile[index].toString().split('/').last));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double y;
}
