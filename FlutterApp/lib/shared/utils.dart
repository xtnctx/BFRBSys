part of 'shared.dart';

List<double> imuParse(String data) {
  double x = double.parse(data.split(',')[0]);
  double y = double.parse(data.split(',')[1]);
  double z = double.parse(data.split(',')[2]);
  return [x, y, z];
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

/// Best use case: value > 255
Uint8List integerToBytes(int value) {
  const length = 4;
  return Uint8List(length)..buffer.asByteData().setInt32(0, value, Endian.little);
}
// ----------------------------------------------------------------------------------

/// Computes Cyclic Redundancy Check values.
///
/// This creates [crc32Table] when initialized. then use the [crc32] to calculate list of 8-bit charcodes.
class Crc32 {
  static const tableSize = 256;
  Uint32List crc32Table = Uint32List(tableSize);

  Crc32() {
    for (var i = 0; i < tableSize; ++i) {
      crc32Table[i] = crc32ForByte(i);
    }
  }

  crc32ForByte(r) {
    for (var j = 0; j < 8; ++j) {
      r = ((r & 1) == 1 ? 0 : 0xedb88320) ^ r >>> 1;
    }
    return r ^ 0xff000000;
  }

  int crc32(List<int> dataIterable) {
    var dataBytes = Uint8List.fromList(dataIterable);
    int crc = 0;
    for (var i = 0; i < dataBytes.length; ++i) {
      var crcLowByte = (crc & 0x000000ff);
      var dataByte = dataBytes[i];
      var tableIndex = crcLowByte ^ dataByte;
      // The last >>> is to convert this into an unsigned 32-bit integer.
      crc = (crc32Table[tableIndex] ^ (crc >>> 8)) >>> 0;
    }
    return crc;
  }
}

Text textInfo(String m, [int statusCode = 0]) {
  Map<int, Color> statusCodeColor = {
    -2: const Color(0xFFE91DC7), // Crash
    -1: const Color(0xFFCA1A1A), // Error
    1: const Color(0xFFD8CB19), // Warning
    2: const Color(0xFF15A349), // Success
    3: const Color(0xFF404BE4), // Info
  };
  return Text(m, style: TextStyle(color: statusCodeColor[statusCode]));
}
