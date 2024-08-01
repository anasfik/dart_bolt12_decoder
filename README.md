# Bolt 12 decoder.

This is a simple decoder for [BOLT 12]() offers, request and invoices in Dart.

This implementation was inspired by the [BOLT 12 decoder]() project in Javascript.

## Usage

```dart
final bolt12Offer =
      "lno1pqqq5xj5wajkcan9gdshx6pq23jhxarfdenjqstyv3ex2umnzcss80xkrjkyrjk43u5dgu8f6a450fg2cnjtg7lhg76c3gtk5gdhshns";

  final res = Bolt12Decoder.decode(bolt12Offer);

  print(res);

  // Output:
  //   {
  //   "type": "offer",
  //   "offer_amount": "0",
  //   "offer_description": "TwelveCash Testing Address",
  //   "offer_node_id": "03bcd61cac41cad58f28d470e9d76b47a50ac4e4b47bf747b588a176a21b785e70",
  //   "valid": true,
  //   "offer_id": "604469d06e2f53909b54ed195eeda2aabbf2227d340840d6bfed6946e6d37161"
  // }

```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/anasfik/dart_bolt12_decoder/issues).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
