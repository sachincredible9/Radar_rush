import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../game.dart';
import '../audio_manager.dart';
import '../level_config.dart';
import 'airplane.dart';

class Gate extends PositionComponent with HasGameRef<AirplaneLandingGame>, TapCallbacks {
  final GateConfig config;
  bool isSelected = false;

  Gate(this.config) : super(position: config.position, size: Vector2(80, 80), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    isSelected = gameRef.selectedPlane?.targetGate == config.position;
  }

  bool get isOccupied => gameRef.world.children
      .whereType<Airplane>()
      .any((p) => p.state == PlaneState.atGate && p.position.distanceTo(config.position) < 20);

  @override
  void render(Canvas canvas) {
    Color gateColor = isOccupied ? Colors.red : (isSelected ? Colors.green : Colors.green.withOpacity(0.2));
    final paint = Paint()
      ..color = gateColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(size.toRect(), paint);
    
    final borderPaint = Paint()
      ..color = gateColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(size.toRect(), borderPaint);

    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(text: '${config.label}\n', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          TextSpan(text: isOccupied ? 'OCCUPIED' : (isSelected ? 'RESERVED' : 'AVAILABLE'), 
                   style: TextStyle(color: Colors.white70, fontSize: 8)),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameRef.selectedPlane != null) {
      if (isOccupied) {
        AudioManager.announce('Gate ${config.label} is occupied!');
      } else {
        gameRef.selectedPlane!.targetGate = config.position;
        AudioManager.announce('Gate ${config.label} assigned.');
      }
    }
  }
}
