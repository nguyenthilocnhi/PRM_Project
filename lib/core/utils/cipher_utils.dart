import 'dart:math';

class CipherUtils {
  /// Generate a random cipher mapping from letters A-Z to numbers 1-26.
  static Map<String, int> generateCipher() {
    final letters = List.generate(26, (i) => String.fromCharCode(65 + i));
    final numbers = List.generate(26, (i) => i + 1)..shuffle(Random());
    
    return Map.fromIterables(letters, numbers);
  }
}
