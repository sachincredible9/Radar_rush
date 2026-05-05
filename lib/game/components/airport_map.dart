import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game.dart';
import '../level_config.dart';

class AirportMap extends SpriteComponent with HasGameRef<AirplaneLandingGame> {
  final LevelConfig config;

  AirportMap(this.config);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(config.backgroundImage);
    size = gameRef.virtualSize;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    
    for (final runway in config.runways) {
      canvas.drawLine(runway.start.toOffset(), runway.end.toOffset(), paint);
      
      final tp = TextPainter(
        text: TextSpan(text: runway.label, style: const TextStyle(color: Colors.cyan, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, runway.start.toOffset());
    }

    final taxiPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    
    canvas.drawLine(config.runways.first.start.toOffset(), config.taxiToGate.toOffset(), taxiPaint);
    canvas.drawLine(config.taxiToGate.toOffset(), config.gates.first.position.toOffset(), taxiPaint);
  }
}
