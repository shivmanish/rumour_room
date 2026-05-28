import 'dart:math';

/// 6-digit room code generator + validator.
class RoomCodeGenerator {
  RoomCodeGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  static const int length = 6;
  static const int _max = 1000000; // 10^length

  String generate() {
    final value = _random.nextInt(_max);
    return value.toString().padLeft(length, '0');
  }

  static bool isValid(String code) =>
      code.length == length && RegExp(r'^\d+$').hasMatch(code);
}
