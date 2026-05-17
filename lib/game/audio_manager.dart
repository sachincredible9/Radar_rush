import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import '../analytics_manager.dart';

class AudioManager {
  static bool _initialized = false;
  static final FlutterTts _tts = FlutterTts();

  static bool isMuted = false;
  static bool isVibrationEnabled = true;

  static AudioPlayer? _selectionPlayer;
  static AudioPlayer? _manualTakeoffPlayer;
  static bool _selectionSoundRequested = false;

  static Future<void> init() async {
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

  static void toggleMute() {
    isMuted = !isMuted;
    AnalyticsManager.logAudioToggle(isMuted);
    if (isMuted) {
      try {
        FlameAudio.bgm.stop();
        _selectionPlayer?.stop();
        _selectionSoundRequested = false;
        _tts.stop();
      } catch (_) {}
    }
  }

  static void playBackground() {
    if (!_initialized || isMuted) return;
    try {
      FlameAudio.bgm.play('engine_hum.mp3', volume: 0.1);
    } catch (_) {}
  }

  static void playRadarBackground() {
    if (!_initialized || isMuted) return;
    try {
      // Loop the radar background music (which contains ATC chatter)
      FlameAudio.bgm.play('radar_music.mp3', volume: 0.3);
    } catch (_) {}
  }

  static void stopRadarBackground() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  static void stopBackground() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  static void playCrowdAmbiance() {
    if (!_initialized || isMuted) return;
    try {
      FlameAudio.bgm.play('airport_crowd.wav', volume: 0.7);
    } catch (_) {}
  }

  static void stopCrowdAmbiance() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  static void playSelectionMusic() {
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

  static void stopSelectionMusic() {
    _selectionSoundRequested = false;
    try {
      _selectionPlayer?.stop();
    } catch (_) {}
  }

  static Future<AudioPlayer?> playTakeoffSound() async {
    if (!_initialized || isMuted) return null;
    try {
      // Stop any existing manual player first to prevent stacking
      await _manualTakeoffPlayer?.stop();
      final player = await FlameAudio.play('airplane_takeoff.wav', volume: 1.0);
      _manualTakeoffPlayer = player;
      return player;
    } catch (_) {
      return null;
    }
  }

  static void playSfx(String name) {
    if (!_initialized || isMuted) return;
    try {
      FlameAudio.play(name);
    } catch (_) {}
  }

  static void stopAllSfx() {
    // This is complex with FlameAudio without tracking every player,
    // but for the manual we can at least stop known looping/long sounds
    stopCrowdAmbiance();
    _tts.stop();
  }

  static void stopTakeoffSound() {
    try {
      _manualTakeoffPlayer?.stop();
      _manualTakeoffPlayer = null;
    } catch (_) {}
  }

  static void stopVoice() {
    try {
      _tts.stop();
    } catch (_) {}
  }

  static void pauseAll() {
    try {
      FlameAudio.bgm.pause();
      _tts.stop();
      _manualTakeoffPlayer?.pause();
    } catch (_) {}
  }

  static void resumeAll() {
    if (isMuted) return;
    try {
      FlameAudio.bgm.resume();
      _manualTakeoffPlayer?.resume();
    } catch (_) {}
  }

  static void announce(String message) {
    if (isMuted) return;
    try {
      _tts.stop().then((_) => _tts.speak(message));
    } catch (_) {
      _tts.speak(message);
    }
  }

  static void toggleVibration() {
    isVibrationEnabled = !isVibrationEnabled;
  }

  static Future<void> vibrate() async {
    if (!isVibrationEnabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500); // 0.5s heavy vibration for crash
      }
    } catch (_) {}
  }
}
