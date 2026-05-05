import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnalyticsManager {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: _analytics);

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase Analytics Initialized');
    } catch (e) {
      debugPrint('Firebase Analytics Initialization Failed: $e');
    }
  }

  // Log App Launch
  static Future<void> logAppLaunch() async {
    await _analytics.logAppOpen();
    await _analytics.logEvent(
      name: 'app_launch_details',
      parameters: {
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Log Screen Size
  static Future<void> logScreenDetails(Size size) async {
    await _analytics.logEvent(
      name: 'device_screen_size',
      parameters: {
        'width': size.width.toInt(),
        'height': size.height.toInt(),
        'aspect_ratio': size.aspectRatio.toStringAsFixed(2),
      },
    );
  }

  // Log Menu Navigation
  static Future<void> logMenuView(String menuName) async {
    await _analytics.logEvent(
      name: 'menu_view',
      parameters: {
        'menu_name': menuName,
      },
    );
  }

  // Log Game Started
  static Future<void> logGameStarted(String airport, String level) async {
    await _analytics.logLevelStart(levelName: level);
    await _analytics.logEvent(
      name: 'game_started',
      parameters: {
        'airport_code': airport,
        'difficulty_level': level,
      },
    );
  }

  // Log Game Over / Milestone
  static Future<void> logGameOver({
    required int score,
    required int landings,
    required int takeoffs,
    required String airport,
    required double maxSpeedReached,
  }) async {
    await _analytics.logEvent(
      name: 'game_over',
      parameters: {
        'final_score': score,
        'total_landings': landings,
        'total_takeoffs': takeoffs,
        'airport_code': airport,
        'max_speed_reached': maxSpeedReached.toInt(),
      },
    );
    await _analytics.logPostScore(score: score);
  }

  // Log Audio Settings
  static Future<void> logAudioToggle(bool isMuted) async {
    await _analytics.logEvent(
      name: 'audio_settings_changed',
      parameters: {
        'is_muted': isMuted ? 1 : 0,
      },
    );
  }

  // Log Specific Flight Action
  static Future<void> logFlightAction(String action, String flightNumber) async {
    await _analytics.logEvent(
      name: 'flight_action',
      parameters: {
        'action_type': action, // e.g., 'landing', 'takeoff', 'taxi'
        'flight_id': flightNumber,
      },
    );
  }
}
