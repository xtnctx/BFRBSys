// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:math';
import 'dart:typed_data';
import 'package:bfrbsys/crc32_checksum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:bfrbsys/colors.dart' as custom_color;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:bfrbsys/providers.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class BluetoothBuilderPage extends StatefulWidget {
  final Icon navBarIcon = const Icon(Icons.monitor_heart_outlined);
  final Icon navBarIconSelected = const Icon(Icons.monitor_heart);
  final String navBarTitle = 'Monitoring System';

  const BluetoothBuilderPage({super.key});

  @override
  State<BluetoothBuilderPage> createState() => _BluetoothBuilderPageState();
}

// class _BluetoothBuilderPageState extends State<BluetoothBuilderPage>
//     with AutomaticKeepAliveClientMixin<BluetoothBuilderPage> {
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
  List<_ChartData>? chartAccData;
  List<_ChartData>? chartGyroData;
  late int count;
  ChartSeriesController? axAxisController;
  ChartSeriesController? ayAxisController;
  ChartSeriesController? azAxisController;

  ChartSeriesController? gxAxisController;
  ChartSeriesController? gyAxisController;
  ChartSeriesController? gzAxisController;

  // @override
  // bool get wantKeepAlive => true;

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

  String? accData;
  String? gyroData;
  String? distData;
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

  // ----------------------------------------------------------------------------------
  // This part is to configure the flutter_blue BluetoothCharacteristic because
  // the read and write values is a type of byte array.
  num bytesToInteger(List<int> bytes) {
    num value = 0;
    if (Endian.host == Endian.big) {
      bytes = List.from(bytes.reversed);
    }
    for (var i = 0, length = bytes.length; i < length; i++) {
      value += bytes[i] * pow(256, i);
    }
    return value;
  }

  Uint8List integerToBytes(int value) {
    /// Best use case: value > 255
    const length = 4;
    return Uint8List(length)..buffer.asByteData().setInt32(0, value, Endian.little);
  }
  // ----------------------------------------------------------------------------------

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

  // ------------------------------------------------------------------------------
  // The rest of these functions are internal implementation details, and shouldn't
  // be called by users of this module.

  void onTransferInProgress() {
    isFileTransferInProgress = true;
  }

  // ------------------------------------------------------------------------------
  // This section contains funrctions you may want to customize for your own page.

  // You'll want to replace these two functions with your own logic, to take what
  // actions your application needs when a file transfer succeeds, or errors out.
  Future<void> onTransferSuccess() async {
    isFileTransferInProgress = false;
    var checksumValue = await fileChecksumCharacteristic?.read();
    var checksum = bytesToInteger(checksumValue!) as int;
    msg("File transfer succeeded: Checksum 0x${checksum.toRadixString(16)}", 2);
  }

  // Called when something has gone wrong with a file transfer.
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
  SizedBox _buildLiveAccChart(context, {double height = 150, double? width}) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SfCartesianChart(
          title: ChartTitle(
            text: 'Accelerometer',
            textStyle: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
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
              color: connectionValue(context) ? custom_color.lineXColor : custom_color.deadLineColor,
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
              color: connectionValue(context) ? custom_color.lineYColor : custom_color.deadLineColor,
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
              color: connectionValue(context) ? custom_color.lineZColor : custom_color.deadLineColor,
              xValueMapper: (_ChartData data, _) => data.t,
              yValueMapper: (_ChartData data, _) => data.z,
              animationDuration: 0,
            )
          ],
        ),
      ),
    );
  }

  SizedBox _buildLiveGyroChart(context, {double height = 150, double? width}) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SfCartesianChart(
          title: ChartTitle(
            text: 'Gyroscope',
            textStyle: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
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
              color: connectionValue(context) ? custom_color.lineXColor : custom_color.deadLineColor,
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
              color: connectionValue(context) ? custom_color.lineYColor : custom_color.deadLineColor,
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
              color: connectionValue(context) ? custom_color.lineZColor : custom_color.deadLineColor,
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

  List<double> dataParse(String data) {
    double x = double.parse(data.split(',')[0]);
    double y = double.parse(data.split(',')[1]);
    double z = double.parse(data.split(',')[2]);
    return [x, y, z];
  }

  // Continously updating the data source based on timer
  void _updateDataSource(Timer timer) {
    List<double> acc = dataParse(accData!);
    List<double> gyro = dataParse(gyroData!);
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

  /* ------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    // super.build(context);
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: LayoutGrid(
        areas: isPortrait
            ? '''
          SfCartesianChart
          CarouselSlider
          Buttons
        '''
            : '''
          SfCartesianChart CarouselSlider
          SfCartesianChart CarouselSlider
          Buttons          Buttons
        ''',
        columnSizes: isPortrait ? [1.fr] : [4.fr, 2.fr],
        rowSizes: isPortrait ? [4.fr, 2.fr, 1.2.fr] : [4.fr, 4.fr, 3.fr],
        // rowSizes: const [auto, auto, auto],
        children: [
          NamedAreaGridPlacement(
            areaName: 'SfCartesianChart',
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: isPortrait
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLiveAccChart(context),
                          const SizedBox(height: 10.0),
                          _buildLiveGyroChart(context),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildLiveAccChart(context, height: 150, width: 220),
                                const SizedBox(width: 10.0),
                                _buildLiveGyroChart(context, height: 150, width: 220),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          NamedAreaGridPlacement(
            areaName: 'CarouselSlider',
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CarouselSlider(
                      options: CarouselOptions(
                        scrollDirection: isPortrait ? Axis.horizontal : Axis.vertical,
                        aspectRatio: isPortrait ? 2.6 : 1,
                        viewportFraction: isPortrait ? 0.5 : 0.75,
                        enlargeCenterPage: true,
                        enlargeStrategy: CenterPageEnlargeStrategy.height,
                      ),
                      items: [
                        // E X T E R N A L S
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: const [
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        'Externals',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(left: 25),
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Theme.of(context).colorScheme.secondaryContainer),
                                              child: const Icon(Icons.sensors),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: const [
                                                  Text('Distance',
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 12,
                                                      )),
                                                  Text('123.45cm', style: TextStyle(fontSize: 15)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(left: 25),
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Theme.of(context).colorScheme.secondaryContainer),
                                              child: const Icon(Icons.thermostat),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: const [
                                                  Text('Temperature',
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 12,
                                                      )),
                                                  Text('35.6°C', style: TextStyle(fontSize: 15)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // S T A T U S
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: const [
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        'Status',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(left: 25),
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Theme.of(context).colorScheme.secondaryContainer),
                                              child: const Icon(Icons.battery_5_bar),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: const [
                                                  Text('Battery level',
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 12,
                                                      )),
                                                  Text('85%', style: TextStyle(fontSize: 15)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(left: 25),
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Theme.of(context).colorScheme.secondaryContainer),
                                              child: const Icon(Icons.scatter_plot),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: const [
                                                  Text('TFLite model',
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 12,
                                                      )),
                                                  Text('In use', style: TextStyle(fontSize: 15)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // M E M E M O R Y   A V A I L A B L E
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: const [
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        'Memory available',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(left: 25),
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Theme.of(context).colorScheme.secondaryContainer),
                                              child: const Icon(Icons.memory, size: 30),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: const [
                                                  Text('256kB', style: TextStyle(fontSize: 20)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          NamedAreaGridPlacement(
            areaName: 'Buttons',
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: isPortrait ? 10 : 120,
                    right: isPortrait ? 10 : 120,
                    top: isPortrait ? 0 : 10,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            )),
                                        onPressed: () {},
                                        child: const Text('ADD ON TARGET'),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              )),
                                          child: Wrap(
                                            children: const [
                                              Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                            ],
                                          ),
                                          onPressed: () {},
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            )),
                                        onPressed: () {},
                                        child: const Text('ADD OFF TARGET'),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              )),
                                          child: Wrap(
                                            children: const [
                                              Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                            ],
                                          ),
                                          onPressed: () {},
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                double h = MediaQuery.of(context).size.height;
                msg('Building model please wait. $h');
              }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
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

class MyTooltip extends StatelessWidget {
  final Widget child;
  final String message;

  const MyTooltip({super.key, required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      message: message,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
  }
}
