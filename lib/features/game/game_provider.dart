import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/level.dart';
import 'storage_service.dart';
import 'audio_manager.dart';

class GameProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Level> _allLevels = [];
  Level? _currentLevel;
  
  // Ánh xạ chữ cái (A-Z) thành số ngẫu nhiên cho level hiện tại
  final Map<String, int> _cipherMap = {};
  
  // Dữ liệu người dùng đã nhập, key là số ngẫu nhiên được gán
  Map<int, String> _userInputs = {};

  bool _isLoading = true;
  bool _isLevelComplete = false;
  bool _isGameOver = false;
  int _hintCount = 3;
  int _maxUnlockedLevel = 1;
  int _errorsCount = 0;

  int? _lastHintTime;
  Timer? _hintTimer;
  int _secondsUntilNextHint = 0;

  List<Level> get allLevels => _allLevels;
  Level? get currentLevel => _currentLevel;
  Map<String, int> get cipherMap => _cipherMap;
  Map<int, String> get userInputs => _userInputs;
  bool get isLoading => _isLoading;
  bool get isLevelComplete => _isLevelComplete;
  bool get isGameOver => _isGameOver;
  int get hintCount => _hintCount;
  int get maxUnlockedLevel => _maxUnlockedLevel;
  int get errorsCount => _errorsCount;
  int get secondsUntilNextHint => _secondsUntilNextHint;

  GameProvider() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dataString = await rootBundle.loadString('assets/data/levels.json');
      final List<dynamic> jsonList = jsonDecode(dataString);
      _allLevels = jsonList.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading levels: $e');
    }

    _hintCount = await _storageService.loadHints();
    _lastHintTime = await _storageService.loadLastHintTime();
    _checkHintRegeneration();
    _startHintTimer();

    _maxUnlockedLevel = await _storageService.loadMaxUnlockedLevel();
    final currentLevelId = await _storageService.loadCurrentLevel();
    await loadLevel(currentLevelId);
  }

  void _checkHintRegeneration() {
    if (_hintCount >= 3 || _lastHintTime == null) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final int elapsed = now - _lastHintTime!;
    final int hoursPassed = elapsed ~/ (60 * 60 * 1000);
    
    if (hoursPassed > 0) {
      _hintCount += hoursPassed;
      if (_hintCount >= 3) {
        _hintCount = 3;
        _lastHintTime = null;
      } else {
        _lastHintTime = _lastHintTime! + (hoursPassed * 60 * 60 * 1000);
      }
      _storageService.saveHints(_hintCount);
      if (_lastHintTime != null) {
        _storageService.saveLastHintTime(_lastHintTime!);
      }
    }
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_hintCount < 3 && _lastHintTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsed = now - _lastHintTime!;
        final int remainingMs = (60 * 60 * 1000) - elapsed;
        
        if (remainingMs <= 0) {
          _checkHintRegeneration();
          notifyListeners();
        } else {
          final int remainingSecs = remainingMs ~/ 1000;
          if (_secondsUntilNextHint != remainingSecs) {
            _secondsUntilNextHint = remainingSecs;
            notifyListeners();
          }
        }
      }
    });
  }

  Future<void> loadLevel(int levelId) async {
    if (_allLevels.isEmpty) return;

    _isLoading = true;
    _isLevelComplete = false;
    _isGameOver = false;
    _errorsCount = 0;
    notifyListeners();

    _currentLevel = _allLevels.firstWhere(
      (lvl) => lvl.id == levelId, 
      orElse: () => _allLevels.first,
    );
    await _storageService.saveCurrentLevel(_currentLevel!.id);

    _generateCipherMap(_currentLevel!);
    _userInputs = await _storageService.loadProgress(_currentLevel!.id);
    
    _checkWinCondition();
    
    // Nếu màn này đã giải xong từ trước, xóa sạch để người chơi có thể chơi lại từ đầu
    if (_isLevelComplete) {
      _userInputs.clear();
      _isLevelComplete = false;
      await _storageService.saveProgress(_currentLevel!.id, _userInputs);
    }

    _isLoading = false;
    notifyListeners();
  }

  void _generateCipherMap(Level level) {
    _cipherMap.clear();
    
    final allGameLetters = <String>{};
    allGameLetters.addAll(level.usedLetters);
    allGameLetters.addAll(level.disabledLetters);

    final random = Random(level.id); 
    List<int> numbers = List.generate(26, (i) => i + 1);
    numbers.shuffle(random);

    int index = 0;
    for (String letter in allGameLetters) {
      if (index < numbers.length) {
        _cipherMap[letter] = numbers[index];
        index++;
      }
    }
  }

  void inputLetter(int number, String letter) {
    if (_currentLevel == null || _isLevelComplete || _isGameOver) return;
    
    // Ignore if cell is already correctly filled
    if (_userInputs.containsKey(number)) return;

    if (letter.isEmpty) {
      _userInputs.remove(number);
    } else {
      String upperLetter = letter.toUpperCase();
      
      // Check if it's correct
      String correctLetter = '';
      for (var entry in _cipherMap.entries) {
        if (entry.value == number) {
          correctLetter = entry.key;
          break;
        }
      }

      if (upperLetter != correctLetter) {
        _errorsCount++;
        AudioManager().playErrorSound();
        if (_errorsCount >= 3) {
          _isGameOver = true;
        }
        notifyListeners();
        return;
      }

      AudioManager().playTapSound();
      _userInputs[number] = upperLetter;
    }
    
    _storageService.saveProgress(_currentLevel!.id, _userInputs);
    _checkWinCondition();
    notifyListeners();
  }

  void deleteLetter(int number) {
    if (_currentLevel == null || _isLevelComplete) return;

    // Ignore if cell is already correctly filled
    if (_userInputs.containsKey(number)) return;

    _userInputs.remove(number);
    _storageService.saveProgress(_currentLevel!.id, _userInputs);
    _checkWinCondition();
    notifyListeners();
  }

  void useHint() {
    if (_currentLevel == null || _isLevelComplete || _hintCount <= 0) return;

    final emptyOrIncorrectNumbers = <int>[];

    for (int c = 0; c < _currentLevel!.clues.length; c++) {
      final clue = _currentLevel!.clues[c];
      for (int l = 0; l < clue.answer.length; l++) {
        final expectedLetter = clue.answer[l];
        final number = _cipherMap[expectedLetter];
        
        if (number != null) {
          final userLetter = _userInputs[number];
          if (userLetter != expectedLetter) {
            if (!emptyOrIncorrectNumbers.contains(number)) {
              emptyOrIncorrectNumbers.add(number);
            }
          }
        }
      }
    }

    if (emptyOrIncorrectNumbers.isEmpty) return;

    final random = Random();
    final targetNumber = emptyOrIncorrectNumbers[random.nextInt(emptyOrIncorrectNumbers.length)];
    
    String targetLetter = '';
    for (var entry in _cipherMap.entries) {
      if (entry.value == targetNumber) {
        targetLetter = entry.key;
        break;
      }
    }

    if (targetLetter.isNotEmpty) {
      if (_hintCount >= 3) {
        _lastHintTime = DateTime.now().millisecondsSinceEpoch;
        _storageService.saveLastHintTime(_lastHintTime!);
      }
      _hintCount--;
      _storageService.saveHints(_hintCount);
      inputLetter(targetNumber, targetLetter);
    }
  }

  void _checkWinCondition() {
    if (_currentLevel == null) return;
    
    bool isWin = true;
    for (int c = 0; c < _currentLevel!.clues.length; c++) {
      final clue = _currentLevel!.clues[c];
      for (int l = 0; l < clue.answer.length; l++) {
        final expectedLetter = clue.answer[l];
        final number = _cipherMap[expectedLetter];
        
        if (number == null) {
          isWin = false;
          break;
        }

        final userLetter = _userInputs[number];
        if (userLetter != expectedLetter) {
          isWin = false;
          break;
        }
      }
      if (!isWin) break;
    }

    _isLevelComplete = isWin;
    if (isWin) {
      AudioManager().playSuccessSound();
      if (_currentLevel!.id >= _maxUnlockedLevel && _currentLevel!.id < _allLevels.length) {
        _maxUnlockedLevel = _currentLevel!.id + 1;
        _storageService.saveMaxUnlockedLevel(_maxUnlockedLevel);
      }
    }
  }

  Future<void> nextLevel() async {
    if (_currentLevel == null) return;
    final nextId = _currentLevel!.id + 1;
    await loadLevel(nextId);
  }

  Future<void> restartLevel() async {
    if (_currentLevel == null) return;
    _userInputs.clear();
    await _storageService.saveProgress(_currentLevel!.id, _userInputs);
    _errorsCount = 0;
    _isGameOver = false;
    _isLevelComplete = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }
}
