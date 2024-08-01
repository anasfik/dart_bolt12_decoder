import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bol12_decoder/utils.dart';

final tagParser = <int, List>{
  0: ['invreq_metadata', (buf) => buf.toString('hex')],
  2: ['offer_chains', fromwireOfferChains],
  4: ['offer_metadata', (buf) => buf.toString('hex')],
  6: ['offer_currency', fromwireOfferCurrency],
  8: ['offer_amount', fromwireOfferAmount],
  10: ['offer_description', fromwireOfferDescription],
  12: ['offer_features', fromwireOfferFeatures],
  14: ['offer_absolute_expiry', fromwireOfferAbsoluteExpiry],
  16: ['offer_paths', fromwireOfferPaths],
  18: ['offer_issuer', fromwireOfferIssuer],
  20: ['offer_quantity_max', fromwireOfferQuantityMax],
  22: ['offer_node_id', fromwireOfferNodeId],
  80: ['invreq_chain', fromwireOfferNodeId],
  82: ['invreq_amount', fromwireInvoiceRequestAmount],
  84: ['invreq_features', fromwireInvoiceRequestFeatures],
  86: ['invreq_quantity', fromwireInvoiceRequestQuantity],
  88: ['invreq_payer_id', fromwireInvoiceRequestPayerKey],
  89: ['invreq_payer_note', fromwireInvoiceRequestPayerNote],
  164: ['invoice_created_at', fromwireInvoiceCreatedAt],
  166: ['invoice_relative_expiry', fromwireInvoiceRelativeExpiry],
  168: ['invoice_payment_hash', fromwireInvoicePaymentHash],
  170: ['invoice_amount', fromwireInvoiceAmount],
  172: ['invoice_fallbacks', fromwireInvoiceFallbacks],
  174: ['invoice_features', fromwireInvoiceFeatures],
  176: ['invoice_node_id', fromwireInvoiceNodeId],
  240: ['signature', fromwireOfferSignature]
};

String stripMsatSuffix(dynamic val) {
  if (val is String) {
    return val.replaceAll('msat', '');
  }
  return val.toString();
}

List<dynamic> fromwireOfferChains(Uint8List buffer) {
  List<dynamic> retarr;
  List<dynamic> v = [];
  while (buffer.isNotEmpty) {
    retarr = fromwireChainHash(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return v;
}

String fromwireOfferCurrency(Uint8List buffer) {
  List<dynamic> retarr = fromwireArrayUtf8(buffer, buffer.length);
  return retarr[0];
}

String fromwireOfferAmount(Uint8List buffer) {
  List<dynamic> retarr = fromwireTu64(buffer);
  return stripMsatSuffix(retarr[0]);
}

String fromwireOfferDescription(Uint8List buffer) {
  List<dynamic> retarr = fromwireArrayUtf8(buffer, buffer.length);
  return retarr[0];
}

List<dynamic> fromwireOfferFeatures(Uint8List buffer) {
  List<dynamic> retarr;
  List<dynamic> v = [];
  while (buffer.isNotEmpty) {
    retarr = fromwireByte(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return v;
}

dynamic fromwireOfferAbsoluteExpiry(Uint8List buffer) {
  List<dynamic> retarr = fromwireTu64(buffer);
  return retarr[0];
}

List<dynamic> fromwireOfferPaths(Uint8List buffer) {
  List<dynamic> retarr;
  List<dynamic> v = [];
  while (buffer.isNotEmpty) {
    retarr = fromwireBlindedPath(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return v;
}

String fromwireOfferIssuer(Uint8List buffer) {
  List<dynamic> retarr = fromwireArrayUtf8(buffer, buffer.length);
  return retarr[0];
}

int fromwireOfferQuantityMax(Uint8List buffer) {
  List<dynamic> retarr = fromwireTu64(buffer);
  return retarr[0];
}

String fromwireOfferNodeId(Uint8List buffer) {
  List<dynamic> retarr = fromwirePoint32(buffer);

  return retarr[0];
}

List<int> fromwireOfferSignature(Uint8List buffer) {
  List<dynamic> retarr = fromwireBip340sig(buffer);
  return retarr[0];
}

String fromwireInvoiceRequestAmount(Uint8List buffer) {
  List<dynamic> retarr = fromwireTu64(buffer);
  return stripMsatSuffix(retarr[0]);
}

List<dynamic> fromwireInvoiceRequestFeatures(Uint8List buffer) {
  List<dynamic> retarr;
  List<dynamic> v = [];
  while (buffer.isNotEmpty) {
    retarr = fromwireByte(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return v;
}

dynamic fromwireInvoiceRequestQuantity(Uint8List buffer) {
  List<dynamic> retarr = fromwireTu64(buffer);
  return retarr[0];
}

List<dynamic> fromwireInvoiceRequestPayerKey(Uint8List buffer) {
  List<dynamic> retarr = fromwirePoint32(buffer);
  return retarr[0];
}

dynamic fromwireInvoiceRequestPayerNote(Uint8List buffer) {
  List<dynamic> retarr = fromwireArrayUtf8(buffer, buffer.length);
  return retarr[0];
}

dynamic fromwireInvoiceAmount(Uint8List buffer) {
  List<dynamic> retarr = fromwireTu64(buffer);
  return stripMsatSuffix(retarr[0]);
}

List<dynamic> fromwireInvoiceFeatures(Uint8List buffer) {
  List<dynamic> retarr;
  List<dynamic> v = [];
  while (buffer.isNotEmpty) {
    retarr = fromwireByte(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return v;
}

List<dynamic> fromwireInvoicePaths(Uint8List buffer) {
  List<dynamic> retarr;
  List<dynamic> v = [];
  while (buffer.isNotEmpty) {
    retarr = fromwireBlindedPath(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return v;
}

List<dynamic> fromwireInvoiceBlindedPay(Uint8List buffer) {
  List<dynamic> retarr;
  List<dynamic> v = [];
  while (buffer.isNotEmpty) {
    retarr = fromwireBlindedPayinfo(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return v;
}

List<dynamic> fromwireInvoiceNodeId(Uint8List buffer) {
  List<dynamic> retarr = fromwirePoint32(buffer);
  return retarr[0];
}

dynamic fromwireInvoiceCreatedAt(Uint8List buffer) {
  List<dynamic> retarr = fromwireTu64(buffer);
  return retarr[0];
}

List<dynamic> fromwireInvoicePaymentHash(Uint8List buffer) {
  List<dynamic> retarr = fromwireSha256(buffer);
  return retarr[0];
}

dynamic fromwireInvoiceRelativeExpiry(Uint8List buffer) {
  List<dynamic> retarr = fromwireTu32(buffer);
  return retarr[0];
}

Map<String, dynamic> fromwireInvoiceFallbacks(Uint8List buffer) {
  List<dynamic> retarr = fromwireByte(buffer);
  dynamic lenfieldNum = retarr[0];
  buffer = retarr[1];
  List<dynamic> v = [];
  for (int i = 0; i < lenfieldNum; i++) {
    retarr = fromwireFallbackAddress(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return {'fallbacks': v};
}

List<dynamic> fromwireOnionmsgPath(Uint8List buffer) {
  List<dynamic> retarr = fromwirePoint(buffer);
  var nodeId = retarr[0];
  buffer = retarr[1];
  retarr = fromwireu16(buffer);
  dynamic lenfieldEnclen = retarr[0];
  buffer = retarr[1];
  List<dynamic> v = [];
  for (int i = 0; i < lenfieldEnclen; i++) {
    retarr = fromwireByte(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return [
    {'node_id': nodeId, 'enctlv': v},
    buffer
  ];
}

List<dynamic> fromwireBlindedPath(Uint8List buffer) {
  List<dynamic> retarr = fromwirePoint(buffer);
  var blinding = retarr[0];
  buffer = retarr[1];
  retarr = fromwireu16(buffer);
  dynamic lenfieldNumHops = retarr[0];
  buffer = retarr[1];
  List<dynamic> v = [];
  for (int i = 0; i < lenfieldNumHops; i++) {
    retarr = fromwireOnionmsgPath(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return [
    {'blinding': blinding, 'path': v},
    buffer
  ];
}

List<dynamic> fromwireBlindedPayinfo(Uint8List buffer) {
  List<dynamic> retarr = fromwireu32(buffer);
  dynamic feeBaseMsat = retarr[0];
  buffer = retarr[1];
  retarr = fromwireu32(buffer);
  dynamic feeProportionalMillionths = retarr[0];
  buffer = retarr[1];
  retarr = fromwireu16(buffer);
  dynamic cltvExpiryDelta = retarr[0];
  buffer = retarr[1];
  retarr = fromwireu16(buffer);
  dynamic lenfieldFlen = retarr[0];
  buffer = retarr[1];
  List<dynamic> v = [];
  for (int i = 0; i < lenfieldFlen; i++) {
    retarr = fromwireByte(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return [
    {
      'fee_base_msat': feeBaseMsat,
      'fee_proportional_millionths': feeProportionalMillionths,
      'cltv_expiry_delta': cltvExpiryDelta,
      'features': v
    },
    buffer
  ];
}

List<dynamic> fromwireFallbackAddress(Uint8List buffer) {
  List<dynamic> retarr = fromwireByte(buffer);
  int version = retarr[0];
  buffer = retarr[1];
  retarr = fromwireu16(buffer);
  int lenfieldLen = retarr[0];
  buffer = retarr[1];
  List<dynamic> v = [];
  for (int i = 0; i < lenfieldLen; i++) {
    retarr = fromwireByte(buffer);
    v.add(retarr[0]);
    buffer = retarr[1];
  }
  return [
    {'version': version, 'address': v},
    buffer
  ];
}

List<dynamic> fromwireArrayUtf8(Uint8List buffer, int len) {
  // Slice the buffer to get the desired length
  Uint8List slicedBuffer = buffer.sublist(0, len);

  // Convert the sliced buffer to a UTF-8 string
  String utf8String = utf8.decode(slicedBuffer);

  // Return the UTF-8 string and the original buffer
  return [utf8String, buffer];
}
