import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyCurrentLevel = 'current_level';
  static const String _keyPrefixProgress = 'progress_level_';
  static const String _keyHints = 'hint_count';
  static const String _keyMaxUnlockedLevel = 'max_unlocked_level';
  
  static const String _keySettingMusic = 'setting_music';
  static const String _keySettingSfx = 'setting_sfx';
  static const String _keySettingVibration = 'setting_vibration';

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Settings
  Future<void> saveSettingMusic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingMusic, value);
  }

  Future<bool> loadSettingMusic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySettingMusic) ?? true;
  }

  Future<void> saveSettingSfx(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingSfx, value);
  }

  Future<bool> loadSettingSfx() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySettingSfx) ?? true;
  }

  Future<void> saveSettingVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingVibration, value);
  }

  Future<bool> loadSettingVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySettingVibration) ?? true;
  }

  Future<void> saveMaxUnlockedLevel(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaxUnlockedLevel, levelId);
  }

  Future<int> loadMaxUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaxUnlockedLevel) ?? 1;
  }

  Future<void> saveHints(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHints, count);
  }

  Future<int> loadHints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHints) ?? 3;
  }

  // Save current level ID
  Future<void> saveCurrentLevel(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentLevel, levelId);
  }

  // Load current level ID (default to 1)
  Future<int> loadCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentLevel) ?? 1;
  }

  // Save progress for a specific level. 
  Future<void> saveProgress(int levelId, Map<int, String> userInputs) async {
    final prefs = await SharedPreferences.getInstance();
    final stringMap = userInputs.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString('$_keyPrefixProgress$levelId', jsonEncode(stringMap));
  }

  // Load progress for a specific level.
  Future<Map<int, String>> loadProgress(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_keyPrefixProgress$levelId');
    if (data != null) {
      try {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(int.parse(key), value.toString()));
      } catch (e) {
        return {};
      }
    }
    return {};
  }
}
