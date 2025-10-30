import 'dart:math';

/// Generates a pseudo-random lowercase alphanumeric identifier.
String generateRandomId({int length = 8}) {
  if (length <= 0) {
    throw ArgumentError.value(length, 'length', 'Must be greater than zero.');
  }

  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rng = Random();
  final buffer = StringBuffer();

  for (var i = 0; i < length; i++) {
    buffer.write(chars[rng.nextInt(chars.length)]);
  }

  return buffer.toString();
}
