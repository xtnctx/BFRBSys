import 'dart:typed_data';

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
