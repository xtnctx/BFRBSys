// ignore_for_file: avoid_print, non_constant_identifier_names

part of 'page_handler.dart';

class BluetoothBuilderPage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.monitor_heart_outlined);
  final Icon navBarIconSelected = const Icon(Icons.monitor_heart);
  final String navBarTitle = 'Monitoring System';

  const BluetoothBuilderPage({super.key});

  @override
  State<BluetoothBuilderPage> createState() => _BluetoothBuilderPageState();
}

class _BluetoothBuilderPageState extends State<BluetoothBuilderPage> {
  /// The Generic Attribute Profile (GATT) is the architechture used
  ///       for bluetooth connectivity.
  ///
  /// The length of uuids and characteristics must be the same and takes the
  ///       reference from the Arduino Nano 33 BLE Sense board.

  /* ========================== S  E  R  V  I  C  E  =========================== */
  final String SERVICE_UUID = 'bf88b656-0000-4a61-86e0-769c741026c0';
  final String TARGET_DEVICE_NAME = "BFRB Sense";
  /* =========================================================================== */

  /* ********************** C H A R A C T E R I S T I C S ********************** */
  final String FILE_BLOCK_UUID = 'bf88b656-3000-4a61-86e0-769c741026c0';
  final String FILE_LENGTH_UUID = 'bf88b656-3001-4a61-86e0-769c741026c0';
  final String FILE_MAXIMUM_LENGTH_UUID = 'bf88b656-3002-4a61-86e0-769c741026c0';
  final String FILE_CHECKSUM_UUID = 'bf88b656-3003-4a61-86e0-769c741026c0';
  final String COMMAND_UUID = 'bf88b656-3004-4a61-86e0-769c741026c0';
  final String TRANSFER_STATUS_UUID = 'bf88b656-3005-4a61-86e0-769c741026c0';
  final String ERROR_MESSAGE_UUID = 'bf88b656-3006-4a61-86e0-769c741026c0';

  final String ACC_DATA_UUID = 'bf88b656-3007-4a61-86e0-769c741026c0';
  final String GYRO_DATA_UUID = 'bf88b656-3008-4a61-86e0-769c741026c0';
  final String DIST_DATA_UUID = 'bf88b656-3009-4a61-86e0-769c741026c0';
  /* =========================================================================== */

  FlutterBlue? flutterBlue;
  BluetoothDevice? device;
  StreamSubscription<dynamic>? deviceState;

  // The characteritics here must match in the peripheral
  BluetoothCharacteristic? fileBlockCharacteristic;
  BluetoothCharacteristic? fileLengthCharacteristic;
  BluetoothCharacteristic? fileMaximumLengthCharacteristic;
  BluetoothCharacteristic? fileChecksumCharacteristic;
  BluetoothCharacteristic? commandCharacteristic;
  BluetoothCharacteristic? transferStatusCharacteristic;
  BluetoothCharacteristic? errorMessageCharacteristic;
  BluetoothCharacteristic? accDataCharacteristic;
  BluetoothCharacteristic? gyroDataCharacteristic;
  BluetoothCharacteristic? distDataCharacteristic;

  bool isFileTransferInProgress = false;
  String info = '>_';
  int infoCode = 0;

  Crc32 crc = Crc32();

  Timer? timer;
  Timer? onCaptureTimer;
  Timer? offCaptureTimer;

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

  @override
  void initState() {
    count = 49;
    chartAccData = <_ChartData>[];
    chartGyroData = <_ChartData>[];
    super.initState();
  }

  Future<void> startConnection(context) async {
    flutterBlue = FlutterBlue.instance;
    bool isOn = await flutterBlue!.isOn;
    if (!isOn) {
      msg("Please turn on your bluetooth", 3);
      return;
    }
    msg('Scanning ... ');
    flutterBlue!.startScan(timeout: const Duration(seconds: 4));

    flutterBlue!.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        if (r.device.name == TARGET_DEVICE_NAME) {
          msg('Target device found. Getting primary service ...');
          device = r.device;
          _connectToDevice(context);
        }
      }
    });
    flutterBlue!.stopScan();
    msg("Can't find your device.", 1);
  }

  Future<void> _discoverServices() async {
    List<BluetoothService> services = await device!.discoverServices();

    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var characteristic in service.characteristics) {
          String characteristicUUID = characteristic.uuid.toString();
          print('################ Searching $characteristicUUID ...');

          // FILE_BLOCK_UUID : fileBlockCharacteristic
          if (characteristicUUID == FILE_BLOCK_UUID) {
            fileBlockCharacteristic = characteristic;
            print('Connected to $FILE_BLOCK_UUID');
          }

          // FILE_LENGTH_UUID : fileLengthCharacteristic
          else if (characteristicUUID == FILE_LENGTH_UUID) {
            fileLengthCharacteristic = characteristic;
            print('Connected to $FILE_LENGTH_UUID');
          }

          // FILE_MAXIMUM_LENGTH_UUID : fileMaximumLengthCharacteristic
          else if (characteristicUUID == FILE_MAXIMUM_LENGTH_UUID) {
            fileMaximumLengthCharacteristic = characteristic;
            print('Connected to $FILE_MAXIMUM_LENGTH_UUID');
          }

          // FILE_CHECKSUM_UUID : fileChecksumCharacteristic
          else if (characteristicUUID == FILE_CHECKSUM_UUID) {
            fileChecksumCharacteristic = characteristic;
            print('Connected to $FILE_CHECKSUM_UUID');
          }

          // COMMAND_UUID : commandCharacteristic
          else if (characteristicUUID == COMMAND_UUID) {
            commandCharacteristic = characteristic;
            print('Connected to $COMMAND_UUID');
          }

          // TRANSFER_STATUS_UUID : transferStatusCharacteristic
          else if (characteristicUUID == TRANSFER_STATUS_UUID) {
            transferStatusCharacteristic = characteristic;
            await transferStatusCharacteristic?.setNotifyValue(true);
            onTransferStatusChanged(transferStatusCharacteristic);
            print('Connected to $TRANSFER_STATUS_UUID');
          }

          // ERROR_MESSAGE_UUID : errorMessageCharacteristic
          else if (characteristicUUID == ERROR_MESSAGE_UUID) {
            errorMessageCharacteristic = characteristic;
            await errorMessageCharacteristic?.setNotifyValue(true);
            onErrorMessageChanged(errorMessageCharacteristic);
            print('Connected to $ERROR_MESSAGE_UUID');
          }

          // ACC_DATA_UUID : accDataCharacteristic
          else if (characteristicUUID == ACC_DATA_UUID) {
            accDataCharacteristic = characteristic;
            await accDataCharacteristic?.setNotifyValue(true);
            print('Connected to $ACC_DATA_UUID');
            _readData(accDataCharacteristic);
          }

          // GYRO_DATA_UUID : gyroDataCharacteristic
          else if (characteristicUUID == GYRO_DATA_UUID) {
            gyroDataCharacteristic = characteristic;
            await gyroDataCharacteristic?.setNotifyValue(true);
            print('Connected to $GYRO_DATA_UUID');
            _readData(gyroDataCharacteristic);
          }

          // DIST_DATA_UUID : distDataCharacteristic
          else if (characteristicUUID == DIST_DATA_UUID) {
            distDataCharacteristic = characteristic;
            await distDataCharacteristic?.setNotifyValue(true);
            print('Connected to $DIST_DATA_UUID');
            _readData(distDataCharacteristic);
          }
        }
        timer = Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);

        msg('Connected to ${device!.name}');
      }
    }
  }

  Future<void> _connectToDevice(context) async {
    if (device == null) return;

    await device!.connect();

    msg('Getting characteristics ...');

    _discoverServices();

    setState(() {
      setConnected(context, true);
    });

    // Listen from sudden disconnection
    deviceState = device!.state.listen((event) {
      if (event == BluetoothDeviceState.disconnected) {
        _disconnectFromDevice(context);
      }
    });
  }

  void _disconnectFromDevice(context) {
    deviceState!.cancel();
    device!.disconnect();
    timer!.cancel();
    msg('Device ${device!.name} disconnected');

    setState(() {
      setConnected(context, false);
      isFileTransferInProgress = false;
      deviceState = null;
      device = null;
      flutterBlue = null;
      timer = null;
    });
  }

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
        if (characteristic.uuid.toString() == ACC_DATA_UUID) {
          accData = parsedData;
        } else if (characteristic.uuid.toString() == GYRO_DATA_UUID) {
          gyroData = parsedData;
        } else if (characteristic.uuid.toString() == DIST_DATA_UUID) {
          distData = parsedData;
        }
      }
    });
  }

  void onTransferStatusChanged(BluetoothCharacteristic? characteristic) {
    characteristic!.value.listen((List<int> value) {
      num statusCode = bytesToInteger(value);

      if (value.isEmpty) return;

      if (statusCode == 0) {
        onTransferSuccess();
      } else if (statusCode == 1) {
        onTransferError();
      } else if (statusCode == 2) {
        onTransferInProgress();
      }
    });
  }

  // Called when an error message is received from the device. This describes what
  // went wrong with the transfer in a user-readable form.
  void onErrorMessageChanged(BluetoothCharacteristic? characteristic) {
    characteristic!.value.listen((List<int> value) {
      List<int> readData = List.from(value);
      String errorMessage = String.fromCharCodes(readData);

      if (readData.isNotEmpty && readData != []) {
        msg("Error message = $errorMessage", -1);
      }
    });
  }

  Future<void> transferFile(Uint8List fileContents) async {
    var maximumLengthValue = await fileMaximumLengthCharacteristic?.read();
    num maximumLength = bytesToInteger(maximumLengthValue!);
    // var maximumLengthArray = Uint32List.fromList(maximumLengthValue!);
    // ByteData byteData = maximumLengthArray.buffer.asByteData();
    // int value = byteData.getUint32(0, Endian.little);
    if (fileContents.length > maximumLength) {
      msg("File length is too long: ${fileContents.length} bytes but maximum is $maximumLength", 1);
      return;
    }

    if (isFileTransferInProgress) {
      msg("Another file transfer is already in progress", 1);
      return;
    }

    var contentsLengthArray = integerToBytes(fileContents.length);
    await fileLengthCharacteristic?.write(contentsLengthArray);

    int fileChecksum = crc.crc32(fileContents);
    var fileChecksumArray = integerToBytes(fileChecksum);
    await fileChecksumCharacteristic?.write(fileChecksumArray);

    await commandCharacteristic?.write([1]);

    sendFileBlock(fileContents, 0);
  }

  Future<void> cancelTransfer() async {
    await commandCharacteristic?.write([2]);
  }

  void onTransferInProgress() {
    isFileTransferInProgress = true;
  }

  Future<void> onTransferSuccess() async {
    isFileTransferInProgress = false;
    var checksumValue = await fileChecksumCharacteristic?.read();
    var checksum = bytesToInteger(checksumValue!) as int;
    msg("File transfer succeeded: Checksum 0x${checksum.toRadixString(16)}", 2);
  }

  void onTransferError() {
    isFileTransferInProgress = false;
    msg("File transfer error", -1);
  }

  void sendFileBlock(fileContents, bytesAlreadySent) {
    var bytesRemaining = fileContents.length - bytesAlreadySent;

    const maxBlockLength = 128;
    int blockLength = min(bytesRemaining, maxBlockLength);
    Uint8List blockView = Uint8List.view(fileContents.buffer, bytesAlreadySent, blockLength);
    print(blockView.toList());

    fileBlockCharacteristic?.write(blockView).then((_) {
      bytesRemaining -= blockLength;
      print(isFileTransferInProgress);
      if ((bytesRemaining > 0) && isFileTransferInProgress) {
        msg("File block written - $bytesRemaining bytes remaining");
        bytesAlreadySent += blockLength;
        sendFileBlock(fileContents, bytesAlreadySent);
      }
    }).catchError((error) {
      print(error);
      msg("File block write error with $bytesRemaining bytes remaining", -1);
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
                    left: 10,
                    right: 10,
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
                    startConnection(context);
                  }
                : () {
                    msg('Hold to disconnect', 1);
                  },
            onLongPress: () {
              if (connectionValue(context)) {
                _disconnectFromDevice(context);
              }
            },
          ),
          SpeedDialChild(
              child: const Icon(Icons.send),
              onTap: () {
                String dataStr =
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.!!!!";
                var fileContents = utf8.encode(dataStr) as Uint8List;
                print("fileContents length is ${fileContents.length}");
                transferFile(fileContents);
              }),
          SpeedDialChild(
              child: const Icon(Icons.cancel),
              onTap: () async {
                msg('Trying to cancel transfer ...');
                await commandCharacteristic?.write([2]);
              }),
          SpeedDialChild(
              child: const Icon(Icons.build),
              onTap: () {
                openBuildForm();
              }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Future openBuildForm() {
    _textController.value = TextEditingValue.empty;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Build'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Enter model name'),
                  controller: _textController,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  msg('Building model please wait.');
                  Navigator.of(context).pop();

                  // await AppStorage.generateCSV(
                  //   data: [header, ...onData, ...offData],
                  //   fileName: _textController.text,
                  // );

                  await AppStorage.generateCSV(data: dummyData, fileName: _textController.text);
                  var token = await UserSecureStorage.getToken();

                  String localPath = await AppStorage.localPath();

                  buildClass.sendInput(
                    filePath: '$localPath/${_textController.text}.csv',
                    modelName: _textController.text,
                    userToken: token,
                  );

                  var response = await buildClass.response;
                  print(response);
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
