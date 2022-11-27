// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:bfrbsys/shared/shared.dart';
import 'package:flutter_blue/flutter_blue.dart';

abstract class GATTProtocolAttr {
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

  BluetoothDevice? get serviceDevice {
    return device;
  }

  List<BluetoothCharacteristic?> get characteristics {
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
}

class BluetoothBuilder extends GATTProtocolAttr {
  StreamController discoverController = StreamController();

  bool isFileTransferInProgress = false;
  Crc32 crc = Crc32();

  Future<void> _discoverServices() async {
    List<BluetoothService> services = await device!.discoverServices();
    discoverController.add(false);

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
            await Future.delayed(const Duration(milliseconds: 500));
            await transferStatusCharacteristic!.setNotifyValue(true);
            _onTransferStatusChanged(transferStatusCharacteristic);
            print('Connected to $TRANSFER_STATUS_UUID');
          }

          // ERROR_MESSAGE_UUID : errorMessageCharacteristic
          else if (characteristicUUID == ERROR_MESSAGE_UUID) {
            errorMessageCharacteristic = characteristic;
            await Future.delayed(const Duration(milliseconds: 500));
            await errorMessageCharacteristic!.setNotifyValue(true);
            _onErrorMessageChanged(errorMessageCharacteristic);
            print('Connected to $ERROR_MESSAGE_UUID');
          }

          // ACC_DATA_UUID : accDataCharacteristic
          else if (characteristicUUID == ACC_DATA_UUID) {
            accDataCharacteristic = characteristic;
            await Future.delayed(const Duration(milliseconds: 500));
            await accDataCharacteristic?.setNotifyValue(true);
            // _readData(accDataCharacteristic);
            print('Connected to $ACC_DATA_UUID');
          }

          // GYRO_DATA_UUID : gyroDataCharacteristic
          else if (characteristicUUID == GYRO_DATA_UUID) {
            gyroDataCharacteristic = characteristic;
            await Future.delayed(const Duration(milliseconds: 500));
            await gyroDataCharacteristic?.setNotifyValue(true);
            // _readData(gyroDataCharacteristic);
            print('Connected to $GYRO_DATA_UUID');
          }

          // DIST_DATA_UUID : distDataCharacteristic
          else if (characteristicUUID == DIST_DATA_UUID) {
            distDataCharacteristic = characteristic;
            await Future.delayed(const Duration(milliseconds: 500));
            await distDataCharacteristic?.setNotifyValue(true);
            // _readData(distDataCharacteristic);
            print('Connected to $DIST_DATA_UUID');
          }
          await Future.delayed(const Duration(milliseconds: 500));
        }
        // timer = Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);

        print('Connected to ${device!.name}');

        discoverController.add(true);

        return;
      }
    }
  }

  void _connectToDevice() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (device == null) return;

    await device!.connect();

    print('Getting characteristics ...');

    await _discoverServices();

    return;
  }

  ///////////////////////////////////

  void _onTransferStatusChanged(BluetoothCharacteristic? characteristic) {
    characteristic!.value.listen((List<int> value) {
      num statusCode = bytesToInteger(value);

      if (value.isEmpty) return;

      if (statusCode == 0) {
        _onTransferSuccess();
      } else if (statusCode == 1) {
        _onTransferError();
      } else if (statusCode == 2) {
        _onTransferInProgress();
      }
    });
  }

  /// Called when an error message is received from the device. This describes what
  /// went wrong with the transfer in a user-readable form.
  void _onErrorMessageChanged(BluetoothCharacteristic? characteristic) {
    characteristic!.value.listen((List<int> value) {
      List<int> readData = List.from(value);
      String errorMessage = String.fromCharCodes(readData);

      if (readData.isNotEmpty && readData != []) {
        print("Error message = $errorMessage -1");
      }
    });
  }

  void _onTransferInProgress() {
    isFileTransferInProgress = true;
  }

  Future<void> _onTransferSuccess() async {
    isFileTransferInProgress = false;
    var checksumValue = await fileChecksumCharacteristic?.read();
    var checksum = bytesToInteger(checksumValue!) as int;
    print("File transfer succeeded: Checksum 0x${checksum.toRadixString(16)} 2");
  }

  void _onTransferError() {
    isFileTransferInProgress = false;
    print("File transfer error -1");
  }

  void _sendFileBlock(fileContents, bytesAlreadySent) {
    var bytesRemaining = fileContents.length - bytesAlreadySent;

    const maxBlockLength = 128;
    int blockLength = min(bytesRemaining, maxBlockLength);
    Uint8List blockView = Uint8List.view(fileContents.buffer, bytesAlreadySent, blockLength);
    print(blockView.toList());

    fileBlockCharacteristic?.write(blockView).then((_) {
      bytesRemaining -= blockLength;
      print(isFileTransferInProgress);
      if ((bytesRemaining > 0) && isFileTransferInProgress) {
        print("File block written - $bytesRemaining bytes remaining");
        bytesAlreadySent += blockLength;
        _sendFileBlock(fileContents, bytesAlreadySent);
      }
    }).catchError((error) {
      print(error);
      print("File block write error with $bytesRemaining bytes remaining -1");
    });
  }

  ///////////////////////////////////

  void connect() async {
    flutterBlue = FlutterBlue.instance;
    bool isOn = await flutterBlue!.isOn;
    if (!isOn) {
      print("Please turn on your bluetooth 3");
      return;
    }
    print('Scanning ... ');

    flutterBlue!.startScan(timeout: const Duration(seconds: 5));
    StreamSubscription subscription = flutterBlue!.scanResults.listen(null);
    subscription.onData((results) {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        if (r.device.name == TARGET_DEVICE_NAME) {
          print('Target device found. Getting primary service ...');
          device = r.device;
          _connectToDevice();
          subscription.cancel();
        }
      }
      print("Can't find your device. 1");
    });
  }

  void disconnect() {
    device!.disconnect();

    print('Device ${device!.name} disconnected');

    isFileTransferInProgress = false;
    discoverController.add(false);
    device = null;
    flutterBlue = null;
  }

  Future<void> cancelTransfer() async {
    await commandCharacteristic?.write([2]);
  }

  Future<void> transferFile(Uint8List fileContents) async {
    var maximumLengthValue = await fileMaximumLengthCharacteristic?.read();
    num maximumLength = bytesToInteger(maximumLengthValue!);
    // var maximumLengthArray = Uint32List.fromList(maximumLengthValue!);
    // ByteData byteData = maximumLengthArray.buffer.asByteData();
    // int value = byteData.getUint32(0, Endian.little);
    if (fileContents.length > maximumLength) {
      print("File length is too long: ${fileContents.length} bytes but maximum is $maximumLength 1");
      return;
    }

    if (isFileTransferInProgress) {
      print("Another file transfer is already in progress 1");
      return;
    }

    var contentsLengthArray = integerToBytes(fileContents.length);
    await fileLengthCharacteristic?.write(contentsLengthArray);

    int fileChecksum = crc.crc32(fileContents);
    var fileChecksumArray = integerToBytes(fileChecksum);
    await fileChecksumCharacteristic?.write(fileChecksumArray);

    await commandCharacteristic?.write([1]);

    _sendFileBlock(fileContents, 0);
  }
}
