import 'package:flutter/foundation.dart';
import 'package:project/features/models/ui_level.dart';
import 'package:project/core/utils/cipher_utils.dart';

class GameController extends ChangeNotifier {
  UiLevel? _currentLevel;
  UiLevel? get currentLevel => _currentLevel;

  Map<String, int> _cipher = {};
  Map<String, int> get cipher => _cipher;

  // Key is the number (1-26), Value is the guessed letter.
  Map<int, String> _userGuesses = {};
  Map<int, String> get userGuesses => _userGuesses;

  int? _selectedNumber;
  int? get selectedNumber => _selectedNumber;

  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;

  bool _isWin = false;
  bool get isWin => _isWin;

  int _mistakes = 0;
  int get mistakes => _mistakes;

  // Maximum mistakes before Game Over
  final int maxMistakes = 3;

  void startLevel(UiLevel level) {
    _currentLevel = level;
    _cipher = CipherUtils.generateCipher();
    _userGuesses = {};
    _selectedNumber = null;
    _isGameOver = false;
    _isWin = false;
    _mistakes = 0;
    notifyListeners();
  }

  void selectNumber(int number) {
    if (_isGameOver || _isWin) return;
    _selectedNumber = number;
    notifyListeners();
  }

  void enterLetter(String letter) {
    if (_selectedNumber == null || _isGameOver || _isWin) return;
    
    // Check if letter was already used (if disabled, keyboard should handle, but verify here)
    if (_currentLevel?.disabledLetters.contains(letter) == true) return;

    final correctLetterEntry = _cipher.entries.firstWhere(
      (entry) => entry.value == _selectedNumber,
      orElse: () => const MapEntry('', 0),
    );

    if (correctLetterEntry.key == letter) {
      // Correct guess
      _userGuesses[_selectedNumber!] = letter;
      _checkWinCondition();
    } else {
      // Incorrect guess
      _mistakes++;
      if (_mistakes >= maxMistakes) {
        _isGameOver = true;
      }
    }
    notifyListeners();
  }
  
  void deleteLetter() {
    if (_selectedNumber == null || _isGameOver || _isWin) return;
    if (_userGuesses.containsKey(_selectedNumber)) {
      _userGuesses.remove(_selectedNumber);
      notifyListeners();
    }
  }

  void hint() {
    if (_selectedNumber == null || _isGameOver || _isWin) return;

    final correctLetterEntry = _cipher.entries.firstWhere(
      (entry) => entry.value == _selectedNumber,
      orElse: () => const MapEntry('', 0),
    );

    if (correctLetterEntry.key.isNotEmpty && !_userGuesses.containsKey(_selectedNumber)) {
      _userGuesses[_selectedNumber!] = correctLetterEntry.key;
      _checkWinCondition();
      notifyListeners();
    }
  }

  void reset() {
    if (_currentLevel != null) {
      startLevel(_currentLevel!);
    }
  }

  void _checkWinCondition() {
    if (_currentLevel == null) return;

    bool allCorrect = true;
    for (String letter in _currentLevel!.usedLetters) {
      final num = _cipher[letter];
      if (num != null) {
        if (_userGuesses[num] != letter) {
          allCorrect = false;
          break;
        }
      }
    }

    if (allCorrect) {
      _isWin = true;
    }
  }
}
