import 'dart:developer';
import 'dart:typed_data';

import 'package:dart_bolt12_decoder/parser.dart';
import 'package:dart_bolt12_decoder/utils.dart';
import 'package:crypto/crypto.dart';

enum Bolt12Type {
  offer,
  request,
  invoice,
}

abstract final class Bolt12Decoder {
  static Map<String, dynamic>? decode(String input) {
    try {
      return _decodeInput(input);
    } catch (e) {
      log("[Bolt12Decoder] Error: $e");

      return null;
    }
  }

  static Map<String, dynamic>? _decodeInput(String input) {
    final alphabet = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
    final isBech32 = {};
    final alphabetMap = {};

    for (int z = 0; z < alphabet.length; z++) {
      final x = alphabet[z];
      alphabetMap[x] = z;
      isBech32[x] = true;
    }

    Bolt12Type? type;
    final words = List<int>.empty(growable: true);

    final indexOfOne = input.lastIndexOf('1');

    final encodedData = input.substring(indexOfOne + 1);
    final prefix = input.substring(0, indexOfOne);

    switch (prefix) {
      case 'lno':
        type = Bolt12Type.offer;
        break;
      case 'lnr':
        type = Bolt12Type.request;
        break;
      case 'lni':
        type = Bolt12Type.invoice;
        break;
      default:
        throw Exception('$prefix is not a proper lightning prefix');
    }

    for (int i = 0; i < encodedData.length; i++) {
      String char = encodedData[i];
      if (alphabetMap.containsKey(char)) {
        words.add(
          alphabetMap[char]!,
        );
      } else {
        print('Character $char not found in ALPHABET_MAP');
      }
    }

    final finalRes = <String, dynamic>{
      'type': type.name,
    };

    final tags = [];
    final unknowns = {};
    final tgcode = <int>[];

    final words_8bit = _convert(words, 5, 8);

    var buffer = Uint8List.fromList(words_8bit);

    if ((words.length * 5) % 8 != 0) {
      buffer = buffer.sublist(0, buffer.length - 1);
    }

    while (buffer.isNotEmpty) {
      final tlvs = [];
      var res = fromwire_bigsize(buffer);

      int tagCode = res[0];

      if (tgcode.isNotEmpty && tagCode <= tgcode[tgcode.length - 1]) {
        throw Exception('TLVs should be in ascending order!');
      }

      tgcode.add(tagCode);

      tlvs.add(tagCode);
      buffer = res[1];

      res = fromwire_bigsize(buffer);

      int tagLength = res[0];

      tlvs.add(tagLength);
      buffer = res[1];
      final tagWords = buffer.sublist(0, tagLength);

      if (tagParser.containsKey(tagCode)) {
        final tagParserList = tagParser[tagCode];
        if (tagParserList == null) {
          print('Invalid tag code $tagCode');

          continue;
        }
        final name = tagParserList[0];
        final parser = tagParserList[1] as Function;

        finalRes[name] = parser(tagWords);
      } else if (tagCode % 2 == 1) {
        unknowns[tagCode] = tagWords;

        finalRes[tagCode.toString()] = tagWords.toString();
      } else {
        if (tagCode != 160 && tagCode != 162) {
          print('Invalid: Unknown even field number $tagCode');
        }
      }

      tlvs.add(tagWords);
      buffer = buffer.sublist(tagLength);

      if ((prefix == 'lno' && tagCode > 0 && tagCode < 80) ||
          ((prefix == 'lni' || prefix == 'lnr') && tagCode < 240)) {
        // Get the first two bytes from the first element of tlvs
        List<int> firstTwoBytes = tlvs.sublist(0, 2).cast<int>();

        // Get the second element of tlvs
        Uint8List thirdElement = tlvs[2];

        // Concatenate the two Uint8Lists
        Uint8List concatenated =
            Uint8List.fromList([...firstTwoBytes, ...thirdElement]);

        // Convert concatenated Uint8List to a hexadecimal string
        String hexString =
            concatenated.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

        tags.add(hexString);
      }
    }

    final bufId = Uint8List.fromList(
      [
        for (final tag in tags) ...hexToBytes(tag),
      ],
    );

    final id = hash256(bufId);

    if (prefix == 'lno') {
      if (check_offer(finalRes)) {
        finalRes["valid"] = true;

        finalRes["offer_id"] = id;
        return finalRes;
      }
    }

    if (prefix == 'lni') {
      if (checkInvoice(finalRes)) {
        finalRes["valid"] = true;
        return finalRes;
      }
    }

    if (prefix == 'lnr') {
      if (checkInvoiceRequest(finalRes)) {
        finalRes["valid"] = true;
        finalRes["invreq_id"] = id;

        return finalRes;
      }
    }

    return null;
  }

  static List<int> _convert(List<int> data, int inBits, int outBits) {
    var value = 0;
    var bits = 0;
    final maxV = (1 << outBits) - 1;

    final result = <int>[];

    for (var i = 0; i < data.length; ++i) {
      value = (value << inBits) | data[i];
      bits += inBits;

      while (bits >= outBits) {
        bits -= outBits;
        result.add((value >> bits) & maxV);
      }
    }

    if (bits > 0) {
      result.add((value << (outBits - bits)) & maxV);
    }
    return result;
  }
}

List fromwire_bigsize(Uint8List buffer) {
  var val = fromwireByte(buffer);
  buffer = val[1];

  late int minval;

  if (val.first == 0xfd) {
    minval = 0xfd;
    val = fromwireu16(buffer);
  } else if (val.first == 0xfe) {
    minval = 0x10000;
    val = fromwireu32(buffer);
  } else if (val.first == 0xff) {
    minval = 0x100000000;
    val = fromwireu64(buffer);
  } else
    minval = 0;
  // if (
  //    minval > val
  // ) {
  //   throw Exception('non minimal-encoded bigsize');
  // }

  return val;
}

bool check_offer(Map<String, dynamic> res) {
  if (!(res.containsKey("offer_description"))) {
    throw Exception('missing description');
  }

  if (!(res.containsKey('offer_node_id'))) {
    throw Exception('missing node_id');
  }

  return true;
}

bool checkInvoice(Map<String, dynamic> res) {
  if (!res.containsKey('amount') ||
      !res.containsKey('description') ||
      !res.containsKey('created_at') ||
      !res.containsKey('payment_hash')) {
    throw Exception(
      '(amount, description, created_at, payment_hash) are mandatory fields!',
    );
  }

  final sec_since_epoch = DateTime.now().millisecondsSinceEpoch / 1000;

  if (res.containsKey('relative_expiry')) {
    if (sec_since_epoch > res['created_at'] + res['relative_expiry']) {
      throw Exception('invoice is expired!');
    }
  } else {
    //Is this 7200 random?
    if (sec_since_epoch > res['created_at'] + 7200) {
      throw Exception('invoice is expired!');
    }
  }

  if (res.containsKey('blinded_path')) {
    if (!res.containsKey('blinded_payinfo')) {
      throw Exception('blinded_payinfo is missing!');
    }
  }

  return true;
}

bool checkInvoiceRequest(Map<String, dynamic> res) {
  if (!res.containsKey('payer_key') ||
      !res.containsKey('offer_id') ||
      !res.containsKey('payer_signature')) {
    throw Exception('(payer_key, offer_id, payer_signature) is mandatory');
  }

  return true;
}

hexToBytes(String hexString) {
  var bytes = <int>[];
  for (var i = 0; i < hexString.length; i += 2) {
    bytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
  }

  return bytes;
}

String hash256(Uint8List bytes) {
  final digest = sha256.convert(bytes);
  return digest.toString();
}
