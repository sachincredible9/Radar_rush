import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import '../service_locator.dart';
import 'analytics_service.dart';

class AudioService {
  bool _initialized = false;
  final FlutterTts _tts = FlutterTts();

  bool isMuted = false;
  bool isVibrationEnabled = true;

  AudioPlayer? _selectionPlayer;
  AudioPlayer? _manualTakeoffPlayer;
  bool _selectionSoundRequested = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage("en-US");
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      
      await FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.loadAll([
        'engine_hum.mp3',
        'collision.mp3',
        'airport_selection.wav',
        'plane_crash.wav',
        'airport_crowd.wav',
        'airplane_takeoff.wav',
        'radar_ping.mp3',
        'radar_music.mp3',
      ]);
      _initialized = true;
    } catch (e) {
      debugPrint('Audio/TTS initialization error: $e');
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
    getIt<AnalyticsService>().logAudioToggle(isMuted);
    if (isMuted) {
      try {
        FlameAudio.bgm.stop();
        _selectionPlayer?.stop();
        _selectionSoundRequested = false;
        _tts.stop();
      } catch (_) {}
    }
  }

  void playBackground() {
    if (!_initialized || isMuted) return;
    try {
      FlameAudio.bgm.play('engine_hum.mp3', volume: 0.1);
    } catch (_) {}
  }

  void playRadarBackground() {
    if (!_initialized || isMuted) return;
    try {
      FlameAudio.bgm.play('radar_music.mp3', volume: 0.3);
    } catch (_) {}
  }

  void stopRadarBackground() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  void stopBackground() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  void playCrowdAmbiance() {
    if (!_initialized || isMuted) return;
    try {
      FlameAudio.bgm.play('airport_crowd.wav', volume: 0.7);
    } catch (_) {}
  }

  void stopCrowdAmbiance() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  void playSelectionMusic() {
    if (!_initialized || isMuted) return;
    _selectionSoundRequested = true;
    try {
      _selectionPlayer?.stop();
      FlameAudio.play('airport_selection.wav', volume: 0.6).then((player) {
        _selectionPlayer = player;
        if (!_selectionSoundRequested) {
          player.stop();
        }
      });
    } catch (_) {}
  }

  void stopSelectionMusic() {
    _selectionSoundRequested = false;
    try {
      _selectionPlayer?.stop();
    } catch (_) {}
  }

  Future<AudioPlayer?> playTakeoffSound() async {
    if (!_initialized || isMuted) return null;
    try {
      await _manualTakeoffPlayer?.stop();
      final player = await FlameAudio.play('airplane_takeoff.wav', volume: 1.0);
      _manualTakeoffPlayer = player;
      return player;
    } catch (_) {
      return null;
    }
  }

  void playSfx(String name) {
    if (!_initialized || isMuted) return;
    try {
      FlameAudio.play(name);
    } catch (_) {}
  }

  void stopAllSfx() {
    stopCrowdAmbiance();
    _tts.stop();
  }

  void stopTakeoffSound() {
    try {
      _manualTakeoffPlayer?.stop();
      _manualTakeoffPlayer = null;
    } catch (_) {}
  }

  void stopVoice() {
    try {
      _tts.stop();
    } catch (_) {}
  }

  void pauseAll() {
    try {
      FlameAudio.bgm.pause();
      _tts.stop();
      _manualTakeoffPlayer?.pause();
    } catch (_) {}
  }

  void resumeAll() {
    if (isMuted) return;
    try {
      FlameAudio.bgm.resume();
      _manualTakeoffPlayer?.resume();
    } catch (_) {}
  }

  void announce(String message) {
    if (isMuted) return;
    try {
      _tts.stop().then((_) => _tts.speak(message));
    } catch (_) {
      _tts.speak(message);
    }
  }

  void toggleVibration() {
    isVibrationEnabled = !isVibrationEnabled;
  }

  Future<void> vibrate() async {
    if (!isVibrationEnabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500);
      }
    } catch (_) {}
  }
}
