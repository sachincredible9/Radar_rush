import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import '../game.dart';

class Background extends ParallaxComponent<AirplaneLandingGame> with HasGameRef<AirplaneLandingGame> {
  @override
  Future<void> onLoad() async {
    parallax = await gameRef.loadParallax(
      [
        ParallaxImageData('background.png'),
      ],
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.5, 0),
      repeat: ImageRepeat.repeatX,
      fill: LayerFill.height,
    );
  }
}
