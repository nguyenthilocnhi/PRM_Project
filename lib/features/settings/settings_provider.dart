import 'package:flutter/foundation.dart';
import 'package:project/features/game/storage_service.dart';
import 'package:project/features/game/audio_manager.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  bool _isVibrationEnabled = true;

  SettingsProvider(this._storageService) {
    _loadSettings();
  }

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;

  Future<void> _loadSettings() async {
    _isMusicEnabled = await _storageService.loadSettingMusic();
    _isSfxEnabled = await _storageService.loadSettingSfx();
    _isVibrationEnabled = await _storageService.loadSettingVibration();
    
    AudioManager().updateSettings(
      isMusicEnabled: _isMusicEnabled,
      isSfxEnabled: _isSfxEnabled,
      isVibrationEnabled: _isVibrationEnabled,
    );
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    await _storageService.saveSettingMusic(_isMusicEnabled);
    AudioManager().updateSettings(
      isMusicEnabled: _isMusicEnabled,
      isSfxEnabled: _isSfxEnabled,
      isVibrationEnabled: _isVibrationEnabled,
    );
    notifyListeners();
  }

  Future<void> toggleSfx() async {
    _isSfxEnabled = !_isSfxEnabled;
    await _storageService.saveSettingSfx(_isSfxEnabled);
    AudioManager().updateSettings(
      isMusicEnabled: _isMusicEnabled,
      isSfxEnabled: _isSfxEnabled,
      isVibrationEnabled: _isVibrationEnabled,
    );
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _isVibrationEnabled = !_isVibrationEnabled;
    await _storageService.saveSettingVibration(_isVibrationEnabled);
    AudioManager().updateSettings(
      isMusicEnabled: _isMusicEnabled,
      isSfxEnabled: _isSfxEnabled,
      isVibrationEnabled: _isVibrationEnabled,
    );
    notifyListeners();
  }
}
