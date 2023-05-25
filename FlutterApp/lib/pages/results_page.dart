part of 'page_handler.dart';

class ResultsPage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.fact_check_outlined);
  final Icon navBarIconSelected = const Icon(Icons.fact_check);
  final String navBarTitle = 'Results';
  final BluetoothBuilder? ble;

  const ResultsPage({super.key, this.ble});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  String? dir;
  List<Map<String, dynamic>> fileBundle = [];
  // List<io.FileSystemEntity> dataFile = [];
  List<String> modelItems = [];
  String modelContents = ''; // tflite model (C-header file)
  String selectedModel = '';

  List<String> historyList = <String>['Accuracy', 'Loss'];
  late String dropdownValue;
  bool chartVisibility = true;
  bool transferWidgetVisibility = true;
  int _selectedIndex = 0;

  List<ChartData> trainLoss = [];
  List<ChartData> valLoss = [];
  List<ChartData> trainAccuracy = [];
  List<ChartData> valAccuracy = [];

  BluetoothBuilder? ble;
  String callbackMsg = '>_';
  int infoCode = 0;
  double sendingProgress = 0.0;

  _getListofData() async {
    dir = await AppStorage.getDir();
    setState(() {
      List<io.FileSystemEntity> dataFile = io.Directory(dir!).listSync();

      List<Map<String, dynamic>> info = [];
      for (var e in dataFile) {
        List<io.FileSystemEntity> modelFolder = io.Directory(e.path).listSync();
        List<io.File> fileContents = [];
        String modelName = e.path.split('/').last;
        int id = 0;
        for (var file in modelFolder) {
          if (file is io.File) {
            fileContents.add(file);
            if (file.path.endsWith('.json')) {
              String jsonEncoded = file.readAsStringSync();
              Map<String, dynamic> jsonDecoded = json.decode(jsonEncoded);
              id = jsonDecoded['id'];
            }
          }
        }
        info.add({modelName: fileContents, 'id': id});
      }

      info.sort((b, a) => a["id"].compareTo(b["id"]));
      for (var item in info) {
        modelItems.add(item.keys.first);
      }

      selectedModel = modelItems[_selectedIndex];
      fileBundle = info;
    });
    _loadCallback(_selectedIndex);

    List files = fileBundle[_selectedIndex].values.first;
    _initModelContents(files);

    print(modelContents);
  }

  @override
  void initState() {
    super.initState();
    _getListofData();
    dropdownValue = historyList.first;
    ble = widget.ble;
    listenCallback();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _initModelContents(List files) {
    for (io.File file in files) {
      if (file.path.endsWith('_model.h')) {
        modelContents = file.readAsStringSync();
        break;
      }
    }
  }

  void listenCallback() {
    ble!.callbackController.stream.asBroadcastStream().listen((List value) {
      // value = [String callbackMessage, double sendingProgress, int statusCode]
      msg(value.first, value.last);
      setState(() {
        sendingProgress = double.parse(value[1].toStringAsFixed(2));
      });
    });
  }

  /// ### [statusCode]
  /// * -2 = Crash (pink-purple)
  /// * -1 = Error (red)
  /// * 1 = Warning (yellow)
  /// * 2 = Success (green)
  /// * 3 = Info (blue)
  void msg(String m, [int statusCode = 0]) {
    setState(() {
      callbackMsg = m;
      infoCode = statusCode;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                              maximum: 100,
                            ),
                            primaryYAxis: NumericAxis(
                              minimum: 0.0,
                              maximum: 1.0,
                              title: AxisTitle(text: dropdownValue, textStyle: const TextStyle(fontSize: 12)),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            series: <ChartSeries>[
                              // Renders line chart
                              FastLineSeries<ChartData, int>(
                                  dataSource: dropdownValue == 'Accuracy' ? trainAccuracy : trainLoss,
                                  color: CustomColor.trainingLineColor,
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) => data.y),
                              FastLineSeries<ChartData, int>(
                                  dataSource: dropdownValue == 'Accuracy' ? valAccuracy : valLoss,
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
                    children: [
                      textInfo(callbackMsg, infoCode),
                    ],
                  ),
                ),
                // Progress bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    height: 10,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: LinearProgressIndicator(
                        value: !(ble!.isConnected) ? 0.0 : sendingProgress,
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
                          ble?.cancelTransfer();
                        },
                        icon: const Icon(Icons.cancel)),
                    IconButton(
                        onPressed: () {
                          if (ble != null) {
                            var fileContents = utf8.encode(modelContents) as Uint8List;
                            print("fileContents length is ${fileContents.length}");
                            ble?.transferFile(fileContents);
                          }
                        },
                        icon: const Icon(Icons.send)),
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
                      _loadCallback(index);

                      List files = fileBundle[index].values.first;
                      _initModelContents(files);
                      print(modelContents);
                    },
                    leading: CircleAvatar(child: Text(modelItems[index][0])),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        // PopupMenuItem 1ss
                        const PopupMenuItem(value: 1, child: Text('View size')),
                        PopupMenuItem(
                            value: 2,
                            onTap: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                showDialog(
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
                              });
                            },
                            child: const Text('Delete')),
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

  _loadCallback(int index) async {
    List<io.File> files = fileBundle[index][selectedModel];
    List<List<dynamic>> data = [];
    for (var file in files) {
      if (file.path.endsWith('_callback.csv')) {
        var stream = file.openRead();
        data = await stream.transform(utf8.decoder).transform(const CsvToListConverter()).toList();
      }
    }

    List<ChartData> tLoss = [];
    List<ChartData> tAccuracy = [];
    List<ChartData> vLoss = [];
    List<ChartData> vAccuracy = [];
    for (int row = 1; row < data.length; row++) {
      // loss
      tLoss.add(ChartData(row, data[row][0]));
      // accuracy
      tAccuracy.add(ChartData(row, data[row][1]));
      // val_loss
      vLoss.add(ChartData(row, data[row][2]));
      // val_accuracy
      vAccuracy.add(ChartData(row, data[row][3]));
    }
    setState(() {
      trainLoss = tLoss;
      trainAccuracy = tAccuracy;
      valLoss = vLoss;
      valAccuracy = vAccuracy;
    });
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double y;
}
