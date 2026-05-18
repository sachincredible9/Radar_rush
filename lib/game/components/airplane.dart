import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../game.dart';
import '../../core/service_locator.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/analytics_service.dart';
import 'gate.dart';
import '../level_config.dart';
import 'airplane/airplane_label.dart';

enum PlaneState { enRoute, landing, landed, taxiing, readyToPark, atGate, takingOff, departed, hold, crashing }

class Airplane extends SpriteComponent with HasGameRef<AirplaneLandingGame>, CollisionCallbacks, TapCallbacks, DragCallbacks {
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
  double _parkingTimer = 0;
  bool _canTakeoff = false;
  Vector2? _readyPosition;
  late AirplaneLabel _label;

  // Adaptive size: Larger for iPad
  Airplane() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    double baseSize = gameRef.size.x > 1000 ? 80 : 60;
    size = Vector2.all(baseSize);
    sprite = await gameRef.loadSprite('airplane_top.png');
    paint = Paint()..blendMode = BlendMode.screen;
      
    // Increase hitbox for easier selection on small screens
    double hitBoxRadius = gameRef.size.x < 500 ? 35 : 25;
    add(CircleHitbox(radius: hitBoxRadius));
    scale = Vector2.all(1.4);
    
    _assignTargetGate();
    
    speed = gameRef.planeBaseSpeed;
    
    getIt<AudioService>().playSfx('radar_ping.mp3');
    getIt<AudioService>().announce(flightNumber);
    
    int side = Random().nextInt(4);
    switch (side) {
      case 0: position = Vector2(Random().nextDouble() * gameRef.size.x, -50); angle = pi / 2; break;
      case 1: position = Vector2(Random().nextDouble() * gameRef.size.x, gameRef.size.y + 50); angle = -pi / 2; break;
      case 2: position = Vector2(-50, Random().nextDouble() * gameRef.size.y); angle = 0; break;
      case 3: position = Vector2(gameRef.size.x + 50, Random().nextDouble() * gameRef.size.y); angle = pi; break;
    }

    _label = AirplaneLabel(
      text: '$flightNumber\n${state.name.toUpperCase()}',
      position: Vector2(size.x / 2, size.y + 20),
    );
    add(_label);
  }

  void _assignTargetGate() {
    final availableGates = gameRef.currentLevel.gates.where((g) {
      bool isOccupied = gameRef.world.children.whereType<Gate>().any((gc) => gc.config.position == g.position && gc.isOccupied);
      bool isTargeted = gameRef.world.children.whereType<Airplane>().any((ap) => ap != this && ap.targetGate == g.position && ap.state != PlaneState.departed && ap.state != PlaneState.crashing);
      return !isOccupied && !isTargeted;
    }).toList();

    if (availableGates.isNotEmpty) {
      targetGate = (availableGates..shuffle()).first.position;
    } else {
      targetGate = (gameRef.currentLevel.gates..shuffle()).first.position;
    }
  }

  @override
  void render(Canvas canvas) {
    if (isSelected) {
      final pulse = (1.0 + 0.15 * sin(gameRef.elapsedTime * 12)).clamp(1.0, 1.3);
      final opacityPulse = (0.5 + 0.3 * sin(gameRef.elapsedTime * 8)).clamp(0.4, 0.8);
      
      // Outer Glow
      canvas.drawCircle(
        (size / 2).toOffset(),
        (size.x / 2 + 15) * pulse,
        Paint()
          ..color = Colors.cyanAccent.withOpacity(0.3 * opacityPulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Main Ring
      canvas.drawCircle(
        (size / 2).toOffset(),
        (size.x / 2 + 12) * pulse,
        Paint()
          ..color = Colors.cyanAccent.withOpacity(opacityPulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );

      // Inner Sharp Ring
      canvas.drawCircle(
        (size / 2).toOffset(),
        (size.x / 2 + 10),
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
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
          getIt<AnalyticsService>().logFlightAction('landing', flightNumber);
          getIt<AudioService>().announce('$flightNumber touchdown. Taxiing to gate.');
          scale = Vector2.all(0.7);
        }
        break;

      case PlaneState.landed:
        speed = 0;
        break;

      case PlaneState.taxiing:
        double distToTaxi = position.distanceTo(gameRef.currentLevel.taxiToGate);
        if (distToTaxi < 60) {
          state = PlaneState.readyToPark;
          speed = 0;
          position = gameRef.currentLevel.taxiToGate.clone();
          _readyPosition = position.clone();
          getIt<AudioService>().announce('$flightNumber ready to park. Drag to the RED highlighted gate.');
        } else {
          speed = gameRef.taxiSpeed;
          _moveTo(gameRef.currentLevel.taxiToGate, dt, multiplier: 10.0);
        }
        break;

      case PlaneState.readyToPark:
        speed = 0;
        break;

      case PlaneState.atGate:
        speed = 0;
        angle = 0;
        if (!_canTakeoff) {
          _parkingTimer += dt;
          if (_parkingTimer >= 4.0) {
            _canTakeoff = true;
            getIt<AudioService>().announce('$flightNumber serviced and ready for takeoff clearance.');
          }
        }
        if (targetGate != null) position = targetGate!;
        break;
      
      case PlaneState.takingOff:
        targetRunway ??= gameRef.getNextRunway();
        _moveTo(targetRunway!.end, dt);
        speed += 120 * dt; // Slightly more acceleration
        double distToEnd = position.distanceTo(targetRunway!.end);
        scale = Vector2.all(0.7 + (1 - distToEnd / 500).clamp(0, 0.5));

        // Gradual volume reduction as it leaves the screen view
        if (_takeoffPlayer != null) {
          // Fade based on distance to any edge
          double margin = 200.0; 
          double distToLeft = position.x;
          double distToRight = gameRef.size.x - position.x;
          double distToTop = position.y;
          double distToBottom = gameRef.size.y - position.y;
          
          double minEdgeDist = [distToLeft, distToRight, distToTop, distToBottom].reduce(min);
          double vol = (minEdgeDist / margin).clamp(0, 1.0);
          _takeoffPlayer!.setVolume(vol);
        }

        if (distToEnd < 10) {
           state = PlaneState.departed;
           gameRef.addPoints(1500, isTakeoff: true);
           getIt<AnalyticsService>().logFlightAction('takeoff', flightNumber);
           _taxiTimer = 0; // Reuse taxiTimer as fade-out timer
        }
        break;

      case PlaneState.departed:
        // Keep moving in the current direction while fading out
        position += Vector2(cos(angle), sin(angle)) * speed * dt;
        speed += 150 * dt;
        _taxiTimer += dt;
        
        if (_takeoffPlayer != null) {
          double vol = (1.0 - _taxiTimer / 2.0).clamp(0, 1.0);
          _takeoffPlayer!.setVolume(vol);
          if (vol <= 0) {
            _takeoffPlayer?.stop();
            _takeoffPlayer = null;
            removeFromParent();
          }
        } else {
          if (_taxiTimer > 2.0) removeFromParent();
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
    _label.updateText(flightNumber, state.name);
    _label.angle = -angle; // Keep text horizontal
    if (state == PlaneState.crashing && _crashTimer > 1.0) {
      _label.hide(); // Hide label during late crash phase
    }

    super.update(dt);
  }

  void _moveTo(Vector2 target, double dt, {double multiplier = 3.0}) {
    Vector2 dir = target - position;
    double dist = dir.length;
    if (dist > 5) {
      double targetAngle = atan2(dir.y, dir.x);
      double angleDiff = targetAngle - angle;
      while (angleDiff > pi) angleDiff -= 2 * pi;
      while (angleDiff < -pi) angleDiff += 2 * pi;
      
      // Reduce rotation speed as we get closer to prevent shaking
      double rotationMultiplier = (dist < 50) ? multiplier * 0.5 : multiplier;
      if (angleDiff.abs() < 0.05) angle = targetAngle;
      else angle += angleDiff * dt * rotationMultiplier;
      
      while (angle > pi) angle -= 2 * pi;
      while (angle < -pi) angle += 2 * pi;
      
      double step = speed * dt;
      if (step > dist) step = dist;
      position += Vector2(cos(angle), sin(angle)) * step;
    } else {
      position = target.clone();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (state == PlaneState.crashing) return;
    gameRef.selectPlane(this);
    isSelected = true;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (state == PlaneState.readyToPark) {
      gameRef.selectPlane(this);
      isSelected = true;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (state == PlaneState.readyToPark) {
      final oldPos = position.clone();
      position += event.localDelta;
      
      if (targetGate != null) {
        double dist = position.distanceTo(targetGate!);
        // Magnetic Snap: If within 40 pixels, snap to gate
        if (dist < 40) {
          position = targetGate!.clone();
          if (oldPos.distanceTo(targetGate!) >= 40) {
            getIt<AudioService>().vibrate(); // Subtle feedback when snapping
          }
        }
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (state == PlaneState.readyToPark && targetGate != null) {
      double dist = position.distanceTo(targetGate!);
      if (dist < 15) { // Tightened tolerance because of snapping
        state = PlaneState.atGate;
        position = targetGate!.clone(); 
        angle = 0;
        _parkingTimer = 0;
        _canTakeoff = false;
        gameRef.addPoints(500);
        
        // Celebration particles at gate
        _triggerSuccessParticles();
        
        getIt<AudioService>().playSfx('airport_selection.mp3');
        getIt<AudioService>().announce('$flightNumber docked. Ground servicing started.');
      } else {
        if (_readyPosition != null) {
          position = _readyPosition!.clone();
          getIt<AudioService>().announce('Incorrect gate. Move $flightNumber to the RED designated gate.');
        }
      }
    }
  }

  void _triggerSuccessParticles() {
    final random = Random();
    gameRef.world.add(
      ParticleSystemComponent(
        position: position.clone(),
        particle: Particle.generate(
          count: 15,
          lifespan: 1.0,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 100),
            speed: Vector2(random.nextDouble() * 100 - 50, random.nextDouble() * 100 - 50),
            child: CircleParticle(
              radius: random.nextDouble() * 3 + 2,
              paint: Paint()..color = Colors.greenAccent,
            ),
          ),
        ),
      ),
    );
  }

  void command(String cmd) {
    if (state == PlaneState.crashing) return;
    switch (cmd) {
      case 'LAND':
        if (state == PlaneState.enRoute || state == PlaneState.hold) {
          state = PlaneState.landing;
          targetRunway = gameRef.getNextRunway();
          getIt<AudioService>().announce('$flightNumber cleared for landing.');
        }
        break;
      case 'HOLD':
        state = PlaneState.hold;
        getIt<AudioService>().announce('$flightNumber enter holding pattern.');
        break;
      case 'TAKEOFF':
        if (state == PlaneState.landed || (state == PlaneState.atGate && _canTakeoff)) {
          final wasLanded = state == PlaneState.landed;
          state = PlaneState.takingOff;
          targetRunway = gameRef.getNextRunway();
          // Give initial speed for immediate takeoff from landed state
          if (wasLanded) speed = 150;
          
          getIt<AudioService>().playTakeoffSound().then((player) {
            _takeoffPlayer = player;
          });
          if (wasLanded) {
             getIt<AudioService>().announce('$flightNumber immediate takeoff cleared.');
          }
        } else if (state == PlaneState.atGate && !_canTakeoff) {
          getIt<AudioService>().announce('$flightNumber is still being serviced.');
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
            getIt<AudioService>().announce('Flight $flightNumber reached gate.');
          }
        }
        break;
      case 'TAXI':
        if (state == PlaneState.landed) {
          state = PlaneState.taxiing;
          // Refresh target gate if current one became occupied or was never assigned correctly
          bool isOccupied = targetGate != null && gameRef.world.children.whereType<Gate>().any((g) => g.config.position == targetGate && g.isOccupied);
          if (targetGate == null || isOccupied) {
            _assignTargetGate();
          }
          gameRef.selectPlane(this);
          isSelected = true;
          getIt<AudioService>().announce('$flightNumber taxiing to apron. Look for the RED designated gate.');
        }
        break;
      case 'TURN_L': 
        angle -= 0.523; 
        getIt<AudioService>().announce('$flightNumber, turning left.');
        break;
      case 'TURN_R': 
        angle += 0.523; 
        getIt<AudioService>().announce('$flightNumber, turning right.');
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
