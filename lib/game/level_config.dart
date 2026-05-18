import 'package:flame/components.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class Runway {
  final Vector2 start;
  final Vector2 end;
  final String label;

  Runway({required this.start, required this.end, required this.label});

  factory Runway.fromJson(Map<String, dynamic> json) {
    return Runway(
      start: Vector2((json['start']['x'] as num).toDouble(), (json['start']['y'] as num).toDouble()),
      end: Vector2((json['end']['x'] as num).toDouble(), (json['end']['y'] as num).toDouble()),
      label: json['label'] as String,
    );
  }
}

class GateConfig {
  final Vector2 position;
  final String label;
  GateConfig({required this.position, required this.label});

  factory GateConfig.fromJson(Map<String, dynamic> json) {
    return GateConfig(
      position: Vector2((json['position']['x'] as num).toDouble(), (json['position']['y'] as num).toDouble()),
      label: json['label'] as String,
    );
  }
}

class LevelConfig {
  final String name;
  final String country;
  final String iataCode;
  final String backgroundImage;
  final List<Runway> runways;
  final Vector2 taxiToGate;
  final List<GateConfig> gates;
  final int landingsToUnlock;

  LevelConfig({
    required this.name,
    required this.country,
    required this.iataCode,
    required this.backgroundImage,
    required this.runways,
    required this.taxiToGate,
    required this.gates,
    this.landingsToUnlock = 0,
  });

  factory LevelConfig.fromJson(Map<String, dynamic> json) {
    return LevelConfig(
      name: json['name'] as String,
      country: json['country'] as String,
      iataCode: json['iataCode'] as String,
      backgroundImage: json['backgroundImage'] as String,
      runways: (json['runways'] as List).map((r) => Runway.fromJson(r)).toList(),
      taxiToGate: Vector2((json['taxiToGate']['x'] as num).toDouble(), (json['taxiToGate']['y'] as num).toDouble()),
      gates: (json['gates'] as List).map((g) => GateConfig.fromJson(g)).toList(),
      landingsToUnlock: json['landingsToUnlock'] as int? ?? 0,
    );
  }

  static List<LevelConfig> allLevels = [];

  static Future<void> loadLevels() async {
    try {
      final String response = await rootBundle.loadString('assets/data/levels.json');
      final List<dynamic> data = json.decode(response);
      allLevels = data.map((l) => LevelConfig.fromJson(l)).toList();
    } catch (e) {
      // Fallback or error handling
      print('Error loading levels: $e');
    }
  }
}
