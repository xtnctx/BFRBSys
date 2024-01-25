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

void unzipFile(String dir) {
// Read the Zip file from disk.
  final bytes = File("$dir/mydata.zip").readAsBytesSync();

// Decode the Zip file
  final archive = ZipDecoder().decodeBytes(bytes);

// Extract the contents of the Zip archive to disk.
  for (final file in archive) {
    final filename = file.name;
    List<String> pathComponents = filename.split('/');
    pathComponents.removeAt(0);
    String itemPath = pathComponents.join('/');

    if (file.isFile) {
      final data = file.content as List<int>;
      File('$dir/$itemPath')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
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
  return Text(m, style: TextStyle(color: statusCodeColor[statusCode], fontSize: 12));
}

List<List> monthToPerWeek(List data) {
  List<int> x = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40
  ];

  List<List> perWeek = [];
  List week = [];

  for (int val in x) {
    week.add(val);
    if (week.length == 7 || val == x.last) {
      perWeek.add(List<int>.from(week));
      week.clear();
    }
  }

  if (perWeek.last.length < 4) {
    List y = perWeek.removeLast();
    for (int val in y) {
      perWeek.last.add(val);
    }
    return perWeek;
  }
  return perWeek;
}

/// data: from wrist-worn device <br>
/// mm: ex: 01 <br>
/// yyyy: ex: 2024 <br>
List extractMonth(Map data, String mm, String yyyy) {
  List<Map<String, dynamic>> extractedMonthData = data["data"]
      .where((entry) => entry["datetime"].startsWith("$mm/") && entry["datetime"].endsWith("/$yyyy"))
      .toList();
  return extractedMonthData;
}
