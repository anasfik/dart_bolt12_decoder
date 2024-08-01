import 'dart:typed_data';

class IntegerType {
  final Uint8List val;
  final int bytelen;
  IntegerType(this.val, this.bytelen);

  List read() {
    if (val.length < bytelen) {
      throw Exception('Not enough bytes!');
    }

    // Convert the relevant bytes to a hexadecimal string
    String hexString = val
        .sublist(0, bytelen)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    // Parse the hexadecimal string as an integer
    int number = int.parse(hexString, radix: 16);

    // Return the parsed number and the remaining buffer
    return [number, val.sublist(bytelen)];
  }

  Uint8List write() {
    // Convert the BigInt value to a hexadecimal string
    String buff =
        val.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    // Check if the hexadecimal string length exceeds the allowed byte length
    if (buff.length > 2 * bytelen) {
      throw Exception('Out of Bounds!');
    }

    // Pad the string with leading zeros to match the required byte length
    buff = buff.padLeft(2 * bytelen, '0');

    // Convert the padded hexadecimal string to a Uint8List
    Uint8List buffer = Uint8List.fromList(List<int>.generate(buff.length ~/ 2,
        (i) => int.parse(buff.substring(2 * i, 2 * i + 2), radix: 16)));

    return buffer;
  }
}

class FundamentalHexType {
  final Uint8List val;
  final int byteslen;

  FundamentalHexType(this.val, this.byteslen);

  List<dynamic> read() {
    if (val.length < byteslen) {
      throw Exception('Not enough bytes!');
    }

    // Convert the byte buffer to a hexadecimal string
    String hexString =
        val.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    // Return the hex string and the remaining buffer
    return [hexString, val.sublist(byteslen)];
  }

  Uint8List write() {
    if (val.length != byteslen) {
      throw Exception('Buffer length is not appropriate');
    }

    // Convert the hexadecimal string back to a Uint8List
    Uint8List buffer =
        Uint8List.fromList(List<int>.generate(val.length, (i) => val[i]));

    return buffer;
  }
}

class TruncatedIntType {
  dynamic val; // Could be either a BigInt or Uint8List based on usage context
  final int bytelen;

  TruncatedIntType(this.val, this.bytelen);

  List<dynamic> read() {
    Uint8List buffer = val is BigInt ? _bigIntToBytes(val) : val;

    if (buffer.length > bytelen) {
      throw Exception('Out of Bounds!');
    }

    if (buffer.isEmpty) {
      buffer = Uint8List.fromList([0]);
    }

    BigInt bigI = BigInt.parse(
        buffer.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(),
        radix: 16);

    // Check if the number can be represented as an int, otherwise use BigInt
    int num;
    try {
      num = bigI.toInt();
    } catch (_) {
      num = 0; // Or handle differently if necessary
    }

    return [num != bigI ? bigI : num, Uint8List(0)];
  }

  Uint8List write() {
    BigInt value = val is BigInt ? val : BigInt.from(val);
    String buff = value.toRadixString(16);

    if (buff.length > 2 * bytelen) {
      throw Exception('Out of Bounds!');
    }

    buff = buff.padLeft(2 * bytelen, '0');
    Uint8List buffer = Uint8List.fromList(List<int>.generate(buff.length ~/ 2,
        (i) => int.parse(buff.substring(2 * i, 2 * i + 2), radix: 16)));

    // Remove leading zero bytes
    int wasteBytes = 0;
    for (int i = 0; i < buffer.length; i++) {
      if (buffer[i] == 0) {
        wasteBytes++;
      } else {
        break;
      }
    }

    return buffer.sublist(wasteBytes);
  }

  Uint8List _bigIntToBytes(BigInt bigInt) {
    var bytes = <int>[];
    var byteMask = BigInt.from(0xFF);

    while (bigInt > BigInt.zero) {
      bytes.insert(0, (bigInt & byteMask).toInt());
      bigInt >>= 8;
    }

    return Uint8List.fromList(bytes);
  }
}
