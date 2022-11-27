// ignore_for_file: avoid_print, non_constant_identifier_names

part of 'page_handler.dart';

class MonitoringPage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.monitor_heart_outlined);
  final Icon navBarIconSelected = const Icon(Icons.monitor_heart);
  final String navBarTitle = 'Monitoring App';

  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  BluetoothBuilder ble = BluetoothBuilder();
  bool isBuildingModel = false;
  String info = '>_';
  int infoCode = 0;

  Crc32 crc = Crc32();

  Timer? timer;
  Timer? onCaptureTimer;
  Timer? offCaptureTimer;
  Timer? loadingTextTimer;

  List<_ChartData>? chartAccData;
  List<_ChartData>? chartGyroData;
  late int count;
  ChartSeriesController? axAxisController;
  ChartSeriesController? ayAxisController;
  ChartSeriesController? azAxisController;

  ChartSeriesController? gxAxisController;
  ChartSeriesController? gyAxisController;
  ChartSeriesController? gzAxisController;

  String? onTargetText;
  String? offTargetText;

  String? accData;
  String? gyroData;
  String? distData;

  NeuralNetworkRequestBuild buildClass = NeuralNetworkRequestBuild();
  final TextEditingController _textController = TextEditingController();

  List<List<String>> dummyData = [
    ["ax", "ay", "az", "gx", "gy", "gz", "class"],
    ['0.574', '0.094', '-0.779', '1.465', '-0.061', '-0.732', '1'],
    ['0.575', '0.103', '-0.791', '1.648', '1.16', '-0.427', '1'],
    ['0.565', '0.115', '-0.796', '0.549', '0.61', '0.183', '1'],
    ['0.586', '0.113', '-0.79', '1.099', '4.395', '-0.366', '1'],
    ['0.579', '0.112', '-0.818', '1.526', '1.892', '-0.122', '1'],
    ['0.578', '0.125', '-0.826', '0.488', '1.709', '0.488', '1'],
    ['0.576', '0.11', '-0.799', '0.305', '0.732', '0.549', '1'],
    ['0.553', '0.11', '-0.819', '1.221', '-0.732', '-0.916', '1'],
    ['0.575', '0.117', '-0.809', '0.916', '0.854', '0.488', '1'],
    ['0.565', '0.112', '-0.814', '0.549', '0.488', '0.793', '1'],
    ['-0.007', '-0.051', '0.982', '0.61', '0.61', '0.122', '0'],
    ['-0.007', '-0.053', '0.981', '0.732', '0.732', '0.366', '0'],
    ['-0.006', '-0.053', '0.982', '0.61', '0.488', '0.183', '0'],
    ['-0.005', '-0.052', '0.984', '0.61', '0.61', '0.366', '0'],
    ['-0.006', '-0.052', '0.983', '0.793', '0.488', '0.183', '0'],
    ['-0.006', '-0.053', '0.982', '0.732', '0.427', '0.305', '0'],
    ['-0.007', '-0.051', '0.983', '0.671', '0.61', '0.366', '0'],
    ['-0.006', '-0.052', '0.983', '0.793', '0.793', '0.305', '0'],
    ['-0.006', '-0.052', '0.982', '0.793', '0.488', '0.366', '0'],
    ['-0.006', '-0.051', '0.982', '0.732', '0.671', '0.305', '0']
  ];

  final List<String> header = ["ax", "ay", "az", "gx", "gy", "gz", "class"];
  List<List<String>> onData = [];
  List<List<String>> offData = [];

  void setConnected(fromContext, bool value) {
    Provider.of<ConnectionProvider>(fromContext, listen: false).setConnected = value;
  }

  bool connectionValue(fromContext) {
    return Provider.of<ConnectionProvider>(fromContext, listen: false).isConnected;
  }

  StreamSubscription? subscription;
  StreamSubscription? deviceState;

  @override
  void initState() {
    count = 49;
    chartAccData = <_ChartData>[];
    chartGyroData = <_ChartData>[];
    super.initState();
  }

  /// ### [statusCode]
  /// * -2 = Crash (pink-purple)
  /// * -1 = Error (red)
  /// * 1 = Warning (yellow)
  /// * 2 = Success (green)
  /// * 3 = Info (blue)
  void msg(String m, [int statusCode = 0]) {
    setState(() {
      info = m;
      infoCode = statusCode;
    });
  }

  Text _textInfo(String m, [int statusCode = 0]) {
    Map<int, Color> statusCodeColor = {
      -2: const Color(0xFFE91DC7), // Crash
      -1: const Color(0xFFCA1A1A), // Error
      1: const Color(0xFFD8CB19), // Warning
      2: const Color(0xFF15A349), // Success
      3: const Color(0xFF404BE4), // Info
    };
    return Text(m, style: TextStyle(color: statusCodeColor[statusCode]));
  }

  /* ------------------------------------------------- */
  // EVENT LISTENERS
  void _readData(BluetoothCharacteristic? characteristic) {
    characteristic!.value.listen((value) {
      List<int> readData = List.from(value);
      String parsedData = String.fromCharCodes(readData);

      if (readData.isNotEmpty && readData != []) {
        if (characteristic.uuid.toString() == ble.ACC_DATA_UUID) {
          accData = parsedData;
        } else if (characteristic.uuid.toString() == ble.GYRO_DATA_UUID) {
          gyroData = parsedData;
        } else if (characteristic.uuid.toString() == ble.DIST_DATA_UUID) {
          distData = parsedData;
        }
      }
    });
  }

  /// Returns the realtime Cartesian line chart.
  SizedBox _buildLiveAccChart(context, {double height = 130, double? width}) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SfCartesianChart(
          title: ChartTitle(
            text: 'Accelerometer',
            textStyle: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.inverseSurface.withAlpha(125),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          plotAreaBorderWidth: 0,
          primaryXAxis: NumericAxis(
            isVisible: false,
          ),
          primaryYAxis: NumericAxis(
            minimum: -2,
            maximum: 2,
            isVisible: false,
          ),
          series: <SplineSeries<_ChartData, int>>[
            SplineSeries<_ChartData, int>(
              name: 'x',
              onRendererCreated: (ChartSeriesController controller) {
                axAxisController = controller;
              },
              dataSource: chartAccData!,
              color: connectionValue(context) ? CustomColor.lineXColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.x,
              animationDuration: 0,
            ),
            SplineSeries<_ChartData, int>(
              name: 'y',
              onRendererCreated: (ChartSeriesController controller) {
                ayAxisController = controller;
              },
              dataSource: chartAccData!,
              color: connectionValue(context) ? CustomColor.lineYColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.y,
              animationDuration: 0,
            ),
            SplineSeries<_ChartData, int>(
              name: 'z',
              onRendererCreated: (ChartSeriesController controller) {
                azAxisController = controller;
              },
              dataSource: chartAccData!,
              color: connectionValue(context) ? CustomColor.lineZColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.z,
              animationDuration: 0,
            )
          ],
        ),
      ),
    );
  }

  SizedBox _buildLiveGyroChart(context, {double height = 130, double? width}) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SfCartesianChart(
          title: ChartTitle(
            text: 'Gyroscope',
            textStyle: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.inverseSurface.withAlpha(125),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          plotAreaBorderWidth: 0,
          primaryXAxis: NumericAxis(
            isVisible: false,
          ),
          primaryYAxis: NumericAxis(
            minimum: -500,
            maximum: 500,
            isVisible: false,
          ),
          series: <SplineSeries<_ChartData, int>>[
            SplineSeries<_ChartData, int>(
              name: 'x',
              onRendererCreated: (ChartSeriesController controller) {
                gxAxisController = controller;
              },
              dataSource: chartGyroData!,
              color: connectionValue(context) ? CustomColor.lineXColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.x,
              animationDuration: 0,
            ),
            SplineSeries<_ChartData, int>(
              name: 'y',
              onRendererCreated: (ChartSeriesController controller) {
                gyAxisController = controller;
              },
              dataSource: chartGyroData!,
              color: connectionValue(context) ? CustomColor.lineYColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.y,
              animationDuration: 0,
            ),
            SplineSeries<_ChartData, int>(
              name: 'z',
              onRendererCreated: (ChartSeriesController controller) {
                gzAxisController = controller;
              },
              dataSource: chartGyroData!,
              color: connectionValue(context) ? CustomColor.lineZColor : CustomColor.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.z,
              animationDuration: 0,
            )
          ],
        ),
      ),
    );
  }

  _connectFromDevice() {
    ble.connect();
    subscription = ble.discoverController.stream.listen(null);

    subscription!.onData((value) {
      print('DAAAAATAAAAA $value');
      // if (value) {
      //   setState(() {
      //     setConnected(context, true);
      //   });
      // }
      if (value) {
        _readData(ble.accDataCharacteristic);
        _readData(ble.gyroDataCharacteristic);
        _readData(ble.distDataCharacteristic);
        timer = Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);
        setState(() {
          setConnected(context, true);
        });

        // Listen from sudden disconnection
        deviceState = ble.device!.state.listen((event) {
          if (event == BluetoothDeviceState.disconnected) {
            _disconnectFromDevice();
          }
        });
        // subscription!.cancel();
      }
    });
  }

  _disconnectFromDevice() {
    ble.disconnect();
    deviceState!.cancel();
    timer!.cancel();
    setState(() {
      setConnected(context, false);
      subscription = null;
      deviceState = null;
      timer = null;
    });
  }

  void updateControllerDataSource(listData, controller, isEdge) {
    if (isEdge) {
      controller?.updateDataSource(
        addedDataIndexes: <int>[listData!.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      controller?.updateDataSource(
        addedDataIndexes: <int>[listData!.length - 1],
      );
    }
  }

  // Continously updating the data source based on timer
  void _updateDataSource(Timer timer) {
    print(accData!);
    List<double> acc = imuParse(accData!);
    List<double> gyro = imuParse(gyroData!);
    chartAccData!.add(_ChartData(count, acc[0], acc[1], acc[2]));
    chartGyroData!.add(_ChartData(count, gyro[0], gyro[1], gyro[2]));

    if (chartAccData!.length == 50) {
      chartAccData!.removeAt(0);
      updateControllerDataSource(chartAccData, axAxisController, true);
      updateControllerDataSource(chartAccData, ayAxisController, true);
      updateControllerDataSource(chartAccData, azAxisController, true);
    } else {
      updateControllerDataSource(chartAccData, axAxisController, false);
      updateControllerDataSource(chartAccData, ayAxisController, false);
      updateControllerDataSource(chartAccData, azAxisController, false);
    }

    if (chartGyroData!.length == 50) {
      chartGyroData!.removeAt(0);
      updateControllerDataSource(chartGyroData, gxAxisController, true);
      updateControllerDataSource(chartGyroData, gyAxisController, true);
      updateControllerDataSource(chartGyroData, gzAxisController, true);
    } else {
      updateControllerDataSource(chartGyroData, gxAxisController, false);
      updateControllerDataSource(chartGyroData, gyAxisController, false);
      updateControllerDataSource(chartGyroData, gzAxisController, false);
    }

    count = count + 1;
  }

  bool isCapturing = false;
  _captureData(BuildContext context, int sender) {
    //
    setState(() {
      isCapturing = true;
    });
    //
    int n = 1;
    onCaptureTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      print('$n seconds');
      if (connectionValue(context)) {
        List<double> acc = imuParse(accData!);
        List<double> gyro = imuParse(gyroData!);

        List<String> captured = [
          // Accelerometer
          acc[0].toString(),
          acc[1].toString(),
          acc[2].toString(),
          // Gyroscope
          gyro[0].toString(),
          gyro[1].toString(),
          gyro[2].toString(),
          // Label
          sender.toString(),
        ];

        if (sender == 1) {
          onData.add(captured);
        } else {
          offData.add(captured);
        }
      }

      if (n == 10) {
        timer.cancel();
        setState(() {
          isCapturing = false;
          if (sender == 1) {
            onTargetText = 'DONE';
          } else {
            offTargetText = 'DONE';
          }
        });
      }
      n += 1;
    });
  }

  /* ------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isDialOpen = ValueNotifier(false);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const ChartHeader(title: 'IMU Sensor'),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLiveAccChart(context),
                  const SizedBox(height: 10.0),
                  _buildLiveGyroChart(context),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const ChartHeader(title: 'Externals'),

          // Externals
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                // Temperature
                ExternalSensorWidget(
                  icon: Icons.thermostat,
                  title: 'Temperature',
                  valueDisplay: '36.5°C',
                ),
                SizedBox(width: 10),
                // Distance
                ExternalSensorWidget(
                  icon: Icons.linear_scale_rounded,
                  title: 'Distance',
                  valueDisplay: '123.45cm',
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 0,
                  ),
                  child: DataButton(
                    // Add
                    onAddOnTarget: (!isCapturing && onTargetText == null)
                        ? () {
                            _captureData(context, 1);
                          }
                        : () {},
                    onAddOffTarget: (!isCapturing && offTargetText == null)
                        ? () {
                            _captureData(context, 0);
                          }
                        : () {},

                    // Delete
                    onDeleteOnTarget: () {
                      setState(() {
                        onTargetText = null;
                        onData.clear();
                      });
                    },
                    onDeleteOffTarget: () {
                      setState(() {
                        offTargetText = null;
                        onData.clear();
                      });
                    },

                    // Label
                    onTargetText: onTargetText,
                    offTargetText: offTargetText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20)),
        child: BottomAppBar(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: ClipRRect(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(child: _textInfo(info, infoCode)),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        closeManually: true,
        openCloseDial: isDialOpen,
        direction: SpeedDialDirection.left,
        spaceBetweenChildren: 10,
        icon: Icons.handyman,
        activeIcon: Icons.close,
        animationDuration: const Duration(milliseconds: 150),
        children: [
          SpeedDialChild(
            child: !connectionValue(context)
                ? const Icon(Icons.bluetooth_connected)
                : const Icon(Icons.bluetooth_disabled),
            onTap: !connectionValue(context)
                ? () {
                    isDialOpen.value = false;
                    _connectFromDevice();
                  }
                : () {
                    msg('Hold to disconnect', 1);
                  },
            onLongPress: () {
              if (connectionValue(context)) {
                isDialOpen.value = false;
                _disconnectFromDevice();
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.send),
            onTap: () {
              isDialOpen.value = false;
              String dataStr =
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.!!!!";
              var fileContents = utf8.encode(dataStr) as Uint8List;
              print("fileContents length is ${fileContents.length}");
              ble.transferFile(fileContents);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.cancel),
            onTap: () {
              isDialOpen.value = false;
              // msg('Trying to cancel transfer ...');
              // ble.cancelTransfer();
              // print(ble.transferStatusCharacteristic!.isNotifying);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.build),
            onTap: !isBuildingModel
                ? () {
                    isDialOpen.value = false;
                    openBuildForm();
                  }
                : () {
                    isDialOpen.value = false;
                  },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  startLoadingBar() {
    int i = 0;
    List<String> m = ['|', '/', '-', '\\'];
    loadingTextTimer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if (i == m.length) i = 0;
      msg("Building model...       ${m[i]}");
      i += 1;
    });
  }

  Future openBuildForm() {
    final formKey = GlobalKey<FormState>();
    _textController.value = TextEditingValue.empty;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Build'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => _textController.text != '' ? null : 'Cannot be empty',
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Enter model name'),
                    controller: _textController,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      isBuildingModel = true;
                    });

                    Navigator.of(context).pop();
                    startLoadingBar();

                    // await AppStorage.generateCSV(
                    //   data: [header, ...onData, ...offData],
                    //   fileName: _textController.text,
                    // );

                    await AppStorage.generateCSV(data: dummyData, fileName: _textController.text);
                    var user = await UserSecureStorage.getUser();
                    var token = await UserSecureStorage.getToken();

                    String localPath = await AppStorage.localPath();

                    buildClass.sendInput(
                      filePath: '$localPath/${user['username']}/data/${_textController.text}.csv',
                      modelName: _textController.text,
                      userToken: token,
                    );

                    Future<TrainedModels> model = buildClass.model;
                    model.then((value) {
                      var response = value.toJson();
                      msg('Build success, ready to send!', 2);
                      print(response);
                    }).onError((error, _) {
                      msg(error.toString(), -1);
                    }).whenComplete(() {
                      setState(() {
                        isBuildingModel = false;
                      });
                      loadingTextTimer!.cancel();
                    });
                  }
                },
                child: const Text('Submit'),
              )
            ],
          );
        });
  }
}

/// Private calss for storing the chart series data points.
class _ChartData {
  _ChartData(this.t, [this.x = 0, this.y = 0, this.z = 0]);
  final int t;
  final num x;
  final num y;
  final num z;
}
