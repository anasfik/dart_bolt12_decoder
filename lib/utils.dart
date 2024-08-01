import 'dart:typed_data';

import 'package:dart_bolt12_decoder/integer.dart';

List fromwireByte(Uint8List buffer) {
  return IntegerType(buffer, 1).read();
}

List fromwireu32(Uint8List buffer) {
  return IntegerType(buffer, 4).read();
}

List fromwireu64(Uint8List buffer) {
  return IntegerType(buffer, 8).read();
}

List fromwireu16(Uint8List buffer) {
  return IntegerType(buffer, 2).read();
}

List<dynamic> fromwireTu16(Uint8List buffer) {
  return TruncatedIntType(buffer, 2).read();
}

List<dynamic> fromwireTu32(Uint8List buffer) {
  return TruncatedIntType(buffer, 4).read();
}

List<dynamic> fromwireTu64(Uint8List buffer) {
  return TruncatedIntType(buffer, 8).read();
}

List fromwireChainHash(Uint8List buffer) {
  return FundamentalHexType(buffer, 32).read();
}

List fromwireChannel_id(Uint8List buffer) {
  return FundamentalHexType(buffer, 32).read();
}

List fromwireSha256(Uint8List buffer) {
  return FundamentalHexType(buffer, 32).read();
}

List fromwirePoint(Uint8List buffer) {
  return FundamentalHexType(buffer, 33).read();
}

List fromwirePoint32(Uint8List buffer) {
  return FundamentalHexType(buffer, 32).read();
}

List fromwireBip340sig(Uint8List buffer) {
  return FundamentalHexType(buffer, 64).read();
}
