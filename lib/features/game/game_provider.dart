import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/level.dart';
import 'storage_service.dart';

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

  List<Level> get allLevels => _allLevels;
  Level? get currentLevel => _currentLevel;
  Map<String, int> get cipherMap => _cipherMap;
  Map<int, String> get userInputs => _userInputs;
  bool get isLoading => _isLoading;
  bool get isLevelComplete => _isLevelComplete;

  GameProvider() {
    _initGame();
  }

  Future<void> _initGame() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dataString = await rootBundle.loadString('assets/data/levels.json');
      final List<dynamic> jsonList = jsonDecode(dataString);
      _allLevels = jsonList.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading levels: $e');
    }

    final currentLevelId = await _storageService.loadCurrentLevel();
    await loadLevel(currentLevelId);
  }

  Future<void> loadLevel(int levelId) async {
    if (_allLevels.isEmpty) return;

    _isLoading = true;
    _isLevelComplete = false;
    notifyListeners();

    _currentLevel = _allLevels.firstWhere(
      (lvl) => lvl.id == levelId, 
      orElse: () => _allLevels.first,
    );
    await _storageService.saveCurrentLevel(_currentLevel!.id);

    _generateCipherMap(_currentLevel!);
    _userInputs = await _storageService.loadProgress(_currentLevel!.id);
    
    _isLoading = false;
    _checkWinCondition();
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
    if (_currentLevel == null || _isLevelComplete) return;

    if (letter.isEmpty) {
      _userInputs.remove(number);
    } else {
      _userInputs[number] = letter.toUpperCase();
    }
    
    _storageService.saveProgress(_currentLevel!.id, _userInputs);
    _checkWinCondition();
    notifyListeners();
  }

  void deleteLetter(int number) {
    if (_currentLevel == null || _isLevelComplete) return;

    _userInputs.remove(number);
    _storageService.saveProgress(_currentLevel!.id, _userInputs);
    _checkWinCondition();
    notifyListeners();
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
  }

  Future<void> nextLevel() async {
    if (_currentLevel == null) return;
    final nextId = _currentLevel!.id + 1;
    await loadLevel(nextId);
  }
}
