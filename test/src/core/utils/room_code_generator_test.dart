import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_room/src/core/utils/room_code_generator.dart';

void main() {
  group('RoomCodeGenerator.generate', () {
    test('produces a 6-character all-digit code', () {
      final gen = RoomCodeGenerator(random: Random(42));
      for (var i = 0; i < 50; i++) {
        final code = gen.generate();
        expect(code.length, 6);
        expect(RoomCodeGenerator.isValid(code), isTrue);
      }
    });

    test('pads short numeric values with leading zeros', () {
      // Random(0).nextInt(1000000) starts small enough that we'll exercise
      // the pad path within a few iterations.
      final gen = RoomCodeGenerator(random: Random(0));
      bool seenLeadingZero = false;
      for (var i = 0; i < 200; i++) {
        if (gen.generate().startsWith('0')) {
          seenLeadingZero = true;
          break;
        }
      }
      expect(seenLeadingZero, isTrue,
          reason: 'expected at least one padded code in 200 samples');
    });
  });

  group('RoomCodeGenerator.isValid', () {
    test('accepts a 6-digit string', () {
      expect(RoomCodeGenerator.isValid('123456'), isTrue);
      expect(RoomCodeGenerator.isValid('000000'), isTrue);
    });

    test('rejects non-digit input', () {
      expect(RoomCodeGenerator.isValid('12345a'), isFalse);
      expect(RoomCodeGenerator.isValid('12 345'), isFalse);
    });

    test('rejects wrong length', () {
      expect(RoomCodeGenerator.isValid(''), isFalse);
      expect(RoomCodeGenerator.isValid('12345'), isFalse);
      expect(RoomCodeGenerator.isValid('1234567'), isFalse);
    });
  });
}
