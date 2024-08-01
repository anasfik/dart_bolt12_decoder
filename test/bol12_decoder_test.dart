import 'package:bol12_decoder/bol12_decoder.dart';
import 'package:test/test.dart';

void main() {
  test(
    "simple text on actual offer",
    () {
      final bolt12Offer =
          "lno1pqqq5xj5wajkcan9gdshx6pq23jhxarfdenjqstyv3ex2umnzcss80xkrjkyrjk43u5dgu8f6a450fg2cnjtg7lhg76c3gtk5gdhshns";

      expect(Bolt12Decoder.decode(bolt12Offer), isNotNull);
    },
  );
}
