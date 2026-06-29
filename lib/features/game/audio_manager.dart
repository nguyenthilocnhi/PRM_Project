import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AudioManager {
  // Singleton instance
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  bool _isVibrationEnabled = true;

  // Initialize and load bgm
  Future<void> init() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void updateSettings({
    required bool isMusicEnabled,
    required bool isSfxEnabled,
    required bool isVibrationEnabled,
  }) {
    _isMusicEnabled = isMusicEnabled;
    _isSfxEnabled = isSfxEnabled;
    _isVibrationEnabled = isVibrationEnabled;

    if (!_isMusicEnabled) {
      _bgmPlayer.pause();
    } else {
      if (_bgmPlayer.state != PlayerState.playing) {
        playBgm();
      }
    }
  }

  Future<void> playBgm() async {
    if (_isMusicEnabled) {
      await _bgmPlayer.play(AssetSource('audio/bgm.wav'));
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> playTapSound() async {
    if (_isSfxEnabled) {
      // Create a temporary player for overlapping tap sounds
      AudioPlayer().play(AssetSource('audio/tap.wav'), mode: PlayerMode.lowLatency);
    }
    if (_isVibrationEnabled) {
      Vibration.vibrate(duration: 50, amplitude: 64);
    }
  }

  Future<void> playSuccessSound() async {
    if (_isSfxEnabled) {
      await _sfxPlayer.play(AssetSource('audio/success.wav'), mode: PlayerMode.lowLatency);
    }
    if (_isVibrationEnabled) {
      Vibration.vibrate(duration: 300, amplitude: 255);
    }
  }

  Future<void> playErrorSound() async {
    if (_isSfxEnabled) {
      await _sfxPlayer.play(AssetSource('audio/error.wav'), mode: PlayerMode.lowLatency);
    }
    if (_isVibrationEnabled) {
      Vibration.vibrate(pattern: [0, 100, 50, 100], intensities: [0, 255, 0, 255]);
    }
  }
}
