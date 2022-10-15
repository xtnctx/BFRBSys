// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:math';
import 'dart:typed_data';
// import 'dart:ffi';
// import 'package:bfrbsys/device_characteristics.dart';
import 'package:bfrbsys/crc32_checksum.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothBuilderPage extends StatefulWidget {
  const BluetoothBuilderPage({super.key});

  @override
  State<BluetoothBuilderPage> createState() => _BluetoothBuilderPageState();
}

class _BluetoothBuilderPageState extends State<BluetoothBuilderPage> {
  /* ========================== P  R  I  M  A  R  Y  =========================== */
  final String SERVICE_UUID = 'bf88b656-0000-4a61-86e0-769c741026c0';
  final String TARGET_DEVICE_NAME = "BFRB Sense";
  /* =========================================================================== */

  /* ****************** C H I L D R E N   O F   P R I M A R Y ****************** */
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

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? scanSubScription;

  late BluetoothDevice device;

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

  String connectionText = "";
  bool isFileTransferInProgress = false;

  Crc32 crc = Crc32();

  List get attr {
    return [
      fileBlockCharacteristic,
      fileLengthCharacteristic,
      fileMaximumLengthCharacteristic,
      fileChecksumCharacteristic,
      commandCharacteristic,
      transferStatusCharacteristic,
      errorMessageCharacteristic,
      accDataCharacteristic,
      gyroDataCharacteristic,
      distDataCharacteristic
    ];
  }

  List get uuids {
    return [
      FILE_BLOCK_UUID,
      FILE_LENGTH_UUID,
      FILE_MAXIMUM_LENGTH_UUID,
      FILE_CHECKSUM_UUID,
      COMMAND_UUID,
      TRANSFER_STATUS_UUID,
      ERROR_MESSAGE_UUID,
      ACC_DATA_UUID,
      GYRO_DATA_UUID,
      DIST_DATA_UUID
    ];
  }

  startConnection() {
    setState(() {
      connectionText = "Start Scanning";
    });

    flutterBlue.scan().listen((results) {
      if (results.device.name == TARGET_DEVICE_NAME) {
        debugPrint('DEVICE found');
        stopScan();
        setState(() {
          connectionText = "Found Target Device";
        });
        device = results.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  discoverServices() async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var characteristic in service.characteristics) {
          String characteristicUUID = characteristic.uuid.toString();
          print('################ Searching $characteristicUUID ...');

          if (characteristicUUID == FILE_BLOCK_UUID) {
            fileBlockCharacteristic = characteristic;
            print('Connected to $FILE_BLOCK_UUID');
          } else if (characteristicUUID == FILE_LENGTH_UUID) {
            fileLengthCharacteristic = characteristic;
            print('Connected to $FILE_LENGTH_UUID');
          } else if (characteristicUUID == FILE_MAXIMUM_LENGTH_UUID) {
            fileMaximumLengthCharacteristic = characteristic;
            print('Connected to $FILE_MAXIMUM_LENGTH_UUID');
          } else if (characteristicUUID == FILE_CHECKSUM_UUID) {
            fileChecksumCharacteristic = characteristic;
            print('Connected to $FILE_CHECKSUM_UUID');
          } else if (characteristicUUID == COMMAND_UUID) {
            commandCharacteristic = characteristic;
            print('Connected to $COMMAND_UUID');
          } else if (characteristicUUID == TRANSFER_STATUS_UUID) {
            transferStatusCharacteristic = characteristic;
            await transferStatusCharacteristic?.setNotifyValue(true);
            print('Connected to $TRANSFER_STATUS_UUID');
            // _readData(transferStatusCharacteristic);
          } else if (characteristicUUID == ERROR_MESSAGE_UUID) {
            errorMessageCharacteristic = characteristic;
            print('Connected to $ERROR_MESSAGE_UUID');
            // _readData(errorMessageCharacteristic);
          } else if (characteristicUUID == ACC_DATA_UUID) {
            accDataCharacteristic = characteristic;
            print('Connected to $ACC_DATA_UUID');
            // _readData(accDataCharacteristic);
          } else if (characteristicUUID == GYRO_DATA_UUID) {
            gyroDataCharacteristic = characteristic;
            print('Connected to $GYRO_DATA_UUID');
            // _readData(gyroDataCharacteristic);
          } else if (characteristicUUID == DIST_DATA_UUID) {
            distDataCharacteristic = characteristic;
            print('Connected to $DIST_DATA_UUID');
            // _readData(distDataCharacteristic);
          }
        }
        setState(() {
          connectionText = "All Ready with ${device.name}";
        });
      }
    }
  }

  connectToDevice() async {
    // ignore: unnecessary_null_comparison
    if (device == null) return;

    setState(() {
      connectionText = "Device Connecting";
    });

    await device.connect();
    debugPrint('DEVICE CONNECTED');
    setState(() {
      connectionText = "Device Connected";
    });

    discoverServices();
  }

  disconnectFromDevice() {
    device.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
    });
  }

  /* ------------------------------------------------- */
  writeData(String data) async {
    // ignore: unnecessary_null_comparison
    if (commandCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    await commandCharacteristic?.write(bytes);
  }

  // EVENT LISTENERS
  _readData(characteristic) async {
    if (!characteristic.isNotifying) {
      await characteristic.setNotifyValue(true);
    }
    characteristic.value.listen((value) {
      List<int> readData = List.from(value);
      String parsedData = String.fromCharCodes(readData);

      if (readData.isNotEmpty && readData != []) {
        print('BLE read data: $parsedData');
      }
    });
  }

  onTransferStatusChanged(characteristic) {
    characteristic.value.listen((List<int> value) {
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
  onErrorMessageChanged(characteristic) {
    characteristic.value.listen((List<int> value) {
      List<int> readData = List.from(value);
      String errorMessage = String.fromCharCodes(readData);

      if (readData.isNotEmpty && readData != []) {
        print("Error message = $errorMessage");
      }
    });
  }

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

  transferFile(Uint8List fileContents) async {
    var maximumLengthValue = await fileMaximumLengthCharacteristic?.read();
    num maximumLength = bytesToInteger(maximumLengthValue!);
    // var maximumLengthArray = Uint32List.fromList(maximumLengthValue!);
    // ByteData byteData = maximumLengthArray.buffer.asByteData();
    // int value = byteData.getUint32(0, Endian.little);
    if (fileContents.length > maximumLength) {
      print("File length is too long: ${fileContents.length} bytes but maximum is $maximumLength");
      return;
    }

    if (isFileTransferInProgress) {
      print("Another file transfer is already in progress");
      return;
    }

    await fileLengthCharacteristic?.write([fileContents.length]);

    int fileChecksum = crc.crc32(fileContents);
    await fileChecksumCharacteristic?.write([fileChecksum]);

    await commandCharacteristic?.write([1]);

    sendFileBlock(fileContents, 0);
  }

  cancelTransfer() async {
    await commandCharacteristic?.write([2]);
  }

  // ------------------------------------------------------------------------------
// The rest of these functions are internal implementation details, and shouldn't
// be called by users of this module.

  onTransferInProgress() {
    isFileTransferInProgress = true;
  }

  // ------------------------------------------------------------------------------
  // This section contains functions you may want to customize for your own page.

  // You'll want to replace these two functions with your own logic, to take what
  // actions your application needs when a file transfer succeeds, or errors out.
  onTransferSuccess() async {
    isFileTransferInProgress = false;
    var checksumValue = await fileChecksumCharacteristic?.read();
    var checksum = bytesToInteger(checksumValue!) as int;
    print("File transfer succeeded: Checksum 0x${checksum.toRadixString(16)}");
  }

  // Called when something has gone wrong with a file transfer.
  onTransferError() {
    isFileTransferInProgress = false;
    print("File transfer error");
  }

  sendFileBlock(fileContents, bytesAlreadySent) async {
    var bytesRemaining = fileContents.length - bytesAlreadySent;

    const maxBlockLength = 128;
    int blockLength = min(bytesRemaining, maxBlockLength);
    Uint8List blockView = Uint8List.view(fileContents, bytesAlreadySent, blockLength);

    fileBlockCharacteristic?.write(blockView).then((_) {
      bytesRemaining -= blockLength;
      if ((bytesRemaining > 0) && isFileTransferInProgress) {
        print("File block written - $bytesRemaining bytes remaining");
        bytesAlreadySent += blockLength;
        sendFileBlock(fileContents, bytesAlreadySent);
      }
    }).catchError((error) {
      print(error);
      print("File block write error with $bytesRemaining bytes remaining, see console");
    });
  }

  /* ------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(connectionText),
        actions: [
          IconButton(
            onPressed: () {
              debugPrint('Actions');
            },
            icon: const Icon(Icons.info_outline),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  debugPrint('Connecting');
                  startConnection();
                },
                child: const Text('Connect'),
              ),
              const SizedBox(
                height: 80,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  transferFile([1, 2, 3] as Uint8List);
                },
                child: const Text('Check'),
              ),
              const SizedBox(
                height: 80,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {},
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BaseModel {
  late Map objects;
  StreamController fetchDoneController = StreamController.broadcast();

  // define constructor here

  fetch() {
    // fetch json from server and then load it to objects
    // emits an event here
    fetchDoneController.add("all done"); // send an arbitrary event
  }

  Stream get fetchDone => fetchDoneController.stream;
}
