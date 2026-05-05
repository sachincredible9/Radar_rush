import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../game.dart';
import '../audio_manager.dart';
import '../level_config.dart';

enum PlaneState { enRoute, landing, landed, taxiing, atGate, takingOff, departed, hold, crashing }

class Airplane extends SpriteComponent with HasGameRef<AirplaneLandingGame>, CollisionCallbacks, TapCallbacks {
  PlaneState state = PlaneState.enRoute;
  double speed = 0; // Initialized in onLoad based on difficulty
  String flightNumber = 'SK-${100 + Random().nextInt(900)}';
  bool isSelected = false;
  Runway? targetRunway;
  Vector2? targetGate;
  AudioPlayer? _takeoffPlayer;
  
  double _crashTimer = 0;
  double _opacity = 1.0;
  double _taxiTimer = 0;
  late TextComponent _label;

  // Adaptive size: Larger for iPad
  Airplane() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    double baseSize = gameRef.size.x > 1000 ? 80 : 60;
    size = Vector2.all(baseSize);
    sprite = await gameRef.loadSprite('airplane_top.png');
    paint = Paint()..blendMode = BlendMode.screen;
      
    add(CircleHitbox(radius: 20));
    scale = Vector2.all(1.4);
    targetGate = (gameRef.currentLevel.gates..shuffle()).first.position;
    speed = gameRef.planeBaseSpeed;
    
    AudioManager.playSfx('radar_ping.mp3');
    AudioManager.announce(flightNumber);
    
    int side = Random().nextInt(4);
    switch (side) {
      case 0: position = Vector2(Random().nextDouble() * gameRef.size.x, -50); angle = pi / 2; break;
      case 1: position = Vector2(Random().nextDouble() * gameRef.size.x, gameRef.size.y + 50); angle = -pi / 2; break;
      case 2: position = Vector2(-50, Random().nextDouble() * gameRef.size.y); angle = 0; break;
      case 3: position = Vector2(gameRef.size.x + 50, Random().nextDouble() * gameRef.size.y); angle = pi; break;
    }



    _label = TextComponent(
      text: '$flightNumber\n${state.name.toUpperCase()}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black45,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, size.y + 5),
    );
    add(_label);
  }

  @override
  void render(Canvas canvas) {
    if (isSelected) {
      final pulse = (1.0 + 0.1 * sin(gameRef.elapsedTime * 10)).clamp(1.0, 1.2);
      canvas.drawCircle(
        (size / 2).toOffset(),
        (size.x / 2 + 10) * pulse,
        Paint()
          ..color = Colors.cyanAccent.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (state == PlaneState.crashing) {
      paint.color = paint.color.withOpacity(_opacity);
      canvas.drawRect(size.toRect(), Paint()..color = Colors.red.withOpacity(0.3 * _opacity)..blendMode = BlendMode.srcATop);
    }
    super.render(canvas);
  }

  @override
  void onRemove() {
    _takeoffPlayer?.stop();
    _takeoffPlayer = null;
    super.onRemove();
  }

  @override
  void update(double dt) {
    if (gameRef.state != GameState.playing && state != PlaneState.crashing) return;

    switch (state) {
      case PlaneState.crashing:
        _crashTimer += dt;
        _opacity = (1.0 - (_crashTimer / 3.0)).clamp(0, 1.0);
        position += Vector2(cos(angle), sin(angle)) * 20 * dt;
        angle += dt * 0.2;
        if (_crashTimer < 2.5) _triggerFireEffect();
        if (_crashTimer >= 3.0) removeFromParent();
        break;

      case PlaneState.enRoute:
        position += Vector2(cos(angle), sin(angle)) * speed * dt;
        if (position.x < -200 || position.x > gameRef.size.x + 200 || 
            position.y < -200 || position.y > gameRef.size.y + 200) {
          angle = atan2(gameRef.size.y / 2 - position.y, gameRef.size.x / 2 - position.x);
        }
        break;
      
      case PlaneState.hold:
        if (speed > 0) {
          angle += dt * 0.5;
          position += Vector2(cos(angle), sin(angle)) * (speed * 0.5) * dt;
        }
        break;
      
      case PlaneState.landing:
        targetRunway ??= gameRef.getNextRunway();
        _moveTo(targetRunway!.start, dt);
        double dist = position.distanceTo(targetRunway!.start);
        scale = Vector2.all(0.7 + (dist / 400).clamp(0, 0.5));
        if (dist < 10) {
          state = PlaneState.landed;
          speed = 0;
          _taxiTimer = 0;
          gameRef.addPoints(500, isLanding: true);
          AudioManager.announce('$flightNumber touchdown. Taxiing to gate.');
          scale = Vector2.all(0.7);
        }
        break;

      case PlaneState.landed:
        speed = 0;
        break;

      case PlaneState.taxiing:
        double distToTaxi = position.distanceTo(gameRef.currentLevel.taxiToGate);
        if (distToTaxi < 20) {
          targetGate ??= gameRef.currentLevel.gates.first.position;
          double distToGate = position.distanceTo(targetGate!);
          speed = (distToGate < 60) ? gameRef.taxiSpeed * 0.4 : gameRef.taxiSpeed;
          if (distToGate < 30) {
            state = PlaneState.atGate;
            speed = 0;
            angle = 0;
            position = targetGate!.clone();
            gameRef.addPoints(500);
            AudioManager.announce('Flight $flightNumber parked. Ready for departure.');
          } else {
            _moveTo(targetGate!, dt, multiplier: 15.0);
          }
        } else {
          speed = gameRef.taxiSpeed;
          _moveTo(gameRef.currentLevel.taxiToGate, dt, multiplier: 10.0);
        }
        break;

      case PlaneState.atGate:
        speed = 0;
        angle = 0;
        if (targetGate != null) position = targetGate!;
        break;
      
      case PlaneState.takingOff:
        targetRunway ??= gameRef.getNextRunway();
        _moveTo(targetRunway!.end, dt);
        speed += 100 * dt;
        double distToEnd = position.distanceTo(targetRunway!.end);
        scale = Vector2.all(0.7 + (1 - distToEnd / 500).clamp(0, 0.5));

        // Gradual volume reduction as it leaves the screen view
        if (_takeoffPlayer != null) {
          // Calculate distance to the nearest edge of the 1000x1000 virtual area
          double margin = 150.0; // Start fading 150 pixels from edge
          double distToLeft = position.x;
          double distToRight = 1000 - position.x;
          double distToTop = position.y;
          double distToBottom = 1000 - position.y;
          
          double minEdgeDist = [distToLeft, distToRight, distToTop, distToBottom].reduce(min);
          double vol = (minEdgeDist / margin).clamp(0, 1.0);
          _takeoffPlayer!.setVolume(vol);
        }

        if (distToEnd < 10) {
           state = PlaneState.departed;
           gameRef.addPoints(1500, isTakeoff: true);
           _takeoffPlayer?.stop();
           _takeoffPlayer = null;
           removeFromParent();
        }
        break;
      
      default: break;
    }
    
    if (state == PlaneState.taxiing) {
      final others = gameRef.world.children.whereType<Airplane>();
      for (final other in others) {
        if (other == this) continue;
        if (other.state == PlaneState.taxiing || other.state == PlaneState.atGate) {
          double dist = position.distanceTo(other.position);
          if (dist < 100) {
            Vector2 toOther = other.position - position;
            double dot = toOther.normalized().dot(Vector2(cos(angle), sin(angle)));
            if (dot > 0.8) { speed = speed * 0.5; break; }
          }
        }
      }
    }
    // Update Label
    _label.text = '$flightNumber\n${state.name.toUpperCase()}';
    _label.angle = -angle; // Keep text horizontal
    if (state == PlaneState.crashing && _crashTimer > 1.0) {
      _label.text = ''; // Hide label during late crash phase
    }

    super.update(dt);
  }

  void _moveTo(Vector2 target, double dt, {double multiplier = 3.0}) {
    Vector2 dir = target - position;
    double dist = dir.length;
    if (dist > 2) {
      double targetAngle = atan2(dir.y, dir.x);
      double angleDiff = targetAngle - angle;
      while (angleDiff > pi) angleDiff -= 2 * pi;
      while (angleDiff < -pi) angleDiff += 2 * pi;
      if (angleDiff.abs() < 0.05) angle = targetAngle;
      else angle += angleDiff * dt * multiplier;
      while (angle > pi) angle -= 2 * pi;
      while (angle < -pi) angle += 2 * pi;
      double step = speed * dt;
      if (step > dist) step = dist;
      position += Vector2(cos(angle), sin(angle)) * step;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (state == PlaneState.crashing) return;
    gameRef.selectPlane(this);
    isSelected = true;
  }

  void command(String cmd) {
    if (state == PlaneState.crashing) return;
    switch (cmd) {
      case 'LAND':
        if (state == PlaneState.enRoute || state == PlaneState.hold) {
          state = PlaneState.landing;
          targetRunway = gameRef.getNextRunway();
          AudioManager.announce('$flightNumber cleared for landing.');
        }
        break;
      case 'HOLD':
        state = PlaneState.hold;
        AudioManager.announce('$flightNumber enter holding pattern.');
        break;
      case 'TAKEOFF':
        if (state == PlaneState.atGate || state == PlaneState.landed || (state == PlaneState.taxiing && speed == 0)) {
          state = PlaneState.takingOff;
          targetRunway = gameRef.getNextRunway();
          AudioManager.playTakeoffSound().then((player) {
            _takeoffPlayer = player;
          });
        }
        break;
      case 'STOP':
        speed = 0;
        if (state == PlaneState.taxiing || state == PlaneState.landed) {
          double distToGate = targetGate != null ? position.distanceTo(targetGate!) : 1000;
          if (distToGate < 50) {
            state = PlaneState.atGate;
            position = targetGate!.clone();
            angle = 0;
            AudioManager.announce('Flight $flightNumber reached gate.');
          }
        }
        break;
      case 'TAXI':
        if (state == PlaneState.landed) {
          state = PlaneState.taxiing;
          AudioManager.announce('$flightNumber taxi to gate.');
        }
        break;
      case 'TURN_L': 
        angle -= 0.523; 
        AudioManager.announce('$flightNumber, turning left.');
        break;
      case 'TURN_R': 
        angle += 0.523; 
        AudioManager.announce('$flightNumber, turning right.');
        break;
      case 'SLOW': speed = (speed - 30).clamp(10, 600); break;
      case 'FAST': speed = (speed + 30).clamp(10, 600); break;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (state == PlaneState.crashing) return;
    if (other is Airplane && state != PlaneState.departed && state != PlaneState.atGate && other.state != PlaneState.atGate) {
      state = PlaneState.crashing;
      _triggerExplosion();
      gameRef.onCollisionOccurred();
    }
  }

  void onAirportCollision() {
    if (state != PlaneState.crashing) {
      state = PlaneState.crashing;
      _triggerExplosion();
      gameRef.onCollisionOccurred();
    }
  }

  void _triggerExplosion() {
    final random = Random();
    gameRef.world.add(
      ParticleSystemComponent(
        priority: 150,
        position: position.clone(),
        particle: Particle.generate(
          count: 20,
          lifespan: 1.5,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 100),
            speed: Vector2(random.nextDouble() * 200 - 100, random.nextDouble() * 200 - 100),
            child: CircleParticle(
              radius: random.nextDouble() * 10 + 5,
              paint: Paint()..color = [Colors.red, Colors.orange, Colors.yellow][random.nextInt(3)],
            ),
          ),
        ),
      ),
    );
  }

  void _triggerFireEffect() {
    final random = Random();
    gameRef.world.add(
      ParticleSystemComponent(
        priority: 150,
        position: position.clone() + Vector2(random.nextDouble() * 20 - 10, random.nextDouble() * 20 - 10),
        particle: Particle.generate(
          count: 3,
          lifespan: 1.0,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(random.nextDouble() * 20 - 10, -100),
            speed: Vector2(random.nextDouble() * 40 - 20, -50),
            child: CircleParticle(
              radius: random.nextDouble() * 8 + 4,
              paint: Paint()..color = (random.nextBool() ? Colors.orange : Colors.red).withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}
