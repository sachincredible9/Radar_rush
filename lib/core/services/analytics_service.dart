import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? observer;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _analytics = FirebaseAnalytics.instance;
      observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      _isInitialized = true;
      debugPrint('Firebase Analytics Initialized');
    } catch (e) {
      debugPrint('Firebase Analytics Initialization Failed: $e');
      _isInitialized = false;
    }
  }

  // Helper to log events safely
  Future<void> _logEvent(String name, {Map<String, Object>? parameters}) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Failed to log event $name: $e');
    }
  }

  // Log App Launch
  Future<void> logAppLaunch() async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logAppOpen();
      await _logEvent(
        'app_launch_details',
        parameters: {
          'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Failed to log app launch: $e');
    }
  }

  // Log Screen Size
  Future<void> logScreenDetails(Size size) async {
    await _logEvent(
      'device_screen_size',
      parameters: {
        'width': size.width.toInt(),
        'height': size.height.toInt(),
        'aspect_ratio': size.aspectRatio.toStringAsFixed(2),
      },
    );
  }

  // Log Menu Navigation
  Future<void> logMenuView(String menuName) async {
    await _logEvent(
      'menu_view',
      parameters: {
        'menu_name': menuName,
      },
    );
  }

  // Log Game Started
  Future<void> logGameStarted(String airport, String level) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logLevelStart(levelName: level);
      await _logEvent(
        'game_started',
        parameters: {
          'airport_code': airport,
          'difficulty_level': level,
        },
      );
    } catch (e) {
      debugPrint('Failed to log game start: $e');
    }
  }

  // Log Game Over / Milestone
  Future<void> logGameOver({
    required int score,
    required int landings,
    required int takeoffs,
    required String airport,
    required double maxSpeedReached,
  }) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _logEvent(
        'game_over',
        parameters: {
          'final_score': score,
          'total_landings': landings,
          'total_takeoffs': takeoffs,
          'airport_code': airport,
          'max_speed_reached': maxSpeedReached.toInt(),
        },
      );
      await _analytics!.logPostScore(score: score);
    } catch (e) {
      debugPrint('Failed to log game over: $e');
    }
  }

  // Log Audio Settings
  Future<void> logAudioToggle(bool isMuted) async {
    await _logEvent(
      'audio_settings_changed',
      parameters: {
        'is_muted': isMuted ? 1 : 0,
      },
    );
  }

  // Log Specific Flight Action
  Future<void> logFlightAction(String action, String flightNumber) async {
    await _logEvent(
      'flight_action',
      parameters: {
        'action_type': action,
        'flight_id': flightNumber,
      },
    );
  }
}
