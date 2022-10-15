// ignore_for_file: avoid_print

import 'package:flutter_blue/flutter_blue.dart';

class DeviceCharacteristics {
  // ignore_for_file: non_constant_identifier_names

  /// The [SERVICE_UUID] sets as the primary service id of the device and
  /// its sub characteristics can be get using the @get[uuids]. Use this
  /// characteristics to set a late BluetoothCharacteristicwhich translates
  /// to [attr] from flutter_blue package https://pub.dev/packages/flutter_blue.
  ///
  /// INFO: The Generic Attribute Profile (GATT) is the architechture used
  ///       for bluetooth connectivity.
  ///
  /// NOTE: The length of [uuids] and [attr] must be the same and takes the
  ///        reference from the Arduino Nano 33 BLE Sense chip.

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

  set assemble(var characteristic) {
    String characteristicUUID = characteristic.uuid.toString();
    for (int index = 0; index < uuids.length; index++) {
      if (characteristicUUID == uuids[index]) {
        fileBlockCharacteristic = characteristic;
        print('Connected to ${uuids[index]}');
      } else if (characteristicUUID == uuids[index]) {
        fileLengthCharacteristic = characteristic;
        print('Connected to ${uuids[index]}');
      } else if (characteristicUUID == uuids[index]) {
        fileMaximumLengthCharacteristic = characteristic;
        print('Connected to ${uuids[index]}');
      } else if (characteristicUUID == uuids[index]) {
        fileChecksumCharacteristic = characteristic;
        print('Connected to ${uuids[index]}');
      } else if (characteristicUUID == uuids[index]) {
        commandCharacteristic = characteristic;
        print('Connected to ${uuids[index]}');
      } else if (characteristicUUID == uuids[index]) {
        transferStatusCharacteristic = characteristic;
        print('Connected to ${uuids[index]}');
      } else if (characteristicUUID == uuids[index]) {
        errorMessageCharacteristic = characteristic;
        print('Connected to ${uuids[index]}');
      } else if (characteristicUUID == uuids[index]) {
        accDataCharacteristic = characteristic;
        print('Connected to ${uuids[index]}');
      } else if (characteristicUUID == uuids[index]) {
        gyroDataCharacteristic = characteristic;
        print('Connected to ${uuids[index]}');
      } else if (characteristicUUID == uuids[index]) {
        distDataCharacteristic = characteristic;
        print('Connected to ${uuids[index]}');
      }
    }
  }

  DeviceCharacteristics() {
    assert(uuids.length == attr.length, "Length of UUIDs and ATTRs doesn't match!");
  }
}
