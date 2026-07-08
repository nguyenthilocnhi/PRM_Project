import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  // Singleton instance
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _tapPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  bool _isVibrationEnabled = true;

  // Initialize and load bgm
  Future<void> init() async {
    try {
      final audioContext = AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
      );
      await AudioPlayer.global.setAudioContext(audioContext);
      await _bgmPlayer.setAudioContext(audioContext);
      await _tapPlayer.setAudioContext(audioContext);
      await _successPlayer.setAudioContext(audioContext);
      await _errorPlayer.setAudioContext(audioContext);

      _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      _bgmPlayer.setVolume(0.3); // Lower BGM volume so SFX can be heard
      
      // Preload audio into memory for ZERO latency
      await _tapPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _tapPlayer.setSourceAsset('audio/tap.wav');
      
      // Use standard MediaPlayer for error and success
      // No need to set lowLatency or preload source, we will use .play()
    } catch (e) {
      debugPrint('Error initializing AudioManager: $e');
    }
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
      if (_bgmPlayer.state == PlayerState.playing || _bgmPlayer.state == PlayerState.paused) {
        // Force resume in case OS natively paused or ducked it without updating Dart state
        await _bgmPlayer.resume();
      } else {
        await _bgmPlayer.play(AssetSource('audio/lo-fi-piano.mp3'));
      }
      // Enforce volume in case the OS ducked it and forgot to restore
      await _bgmPlayer.setVolume(0.3);
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> playTapSound() async {
    if (_isSfxEnabled) {
      if (_tapPlayer.state == PlayerState.playing) {
        await _tapPlayer.stop();
      }
      await _tapPlayer.resume();
    }
  }

  Future<void> playSuccessSound() async {
    if (_isSfxEnabled) {
      await _successPlayer.stop();
      await _successPlayer.play(AssetSource('audio/game-win-sound.wav'));
    }
    if (_isVibrationEnabled) {
      // Light vibration (duration only to support all devices)
      Vibration.vibrate(duration: 100);
    }
    // Safety net: OS might natively duck/pause BGM due to MediaPlayer or Vibration.
    // We enforce a resume after the sound/vibration finishes.
    Future.delayed(const Duration(milliseconds: 2000), () {
      playBgm();
    });
  }

  Future<void> playErrorSound() async {
    if (_isSfxEnabled) {
      await _errorPlayer.stop();
      await _errorPlayer.play(AssetSource('audio/error.wav'));
    }
    if (_isVibrationEnabled) {
      // Light vibration (duration only)
      Vibration.vibrate(duration: 100);
    }
    // Safety net: OS might natively duck/pause BGM.
    Future.delayed(const Duration(milliseconds: 500), () {
      playBgm();
    });
  }

  Future<void> playTickVibration() async {
    if (_isVibrationEnabled) {
      Vibration.vibrate(duration: 30);
    }
  }
}
