import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'components/airplane.dart';
import 'components/airport_map.dart';
import 'components/gate.dart';
import 'level_config.dart';
import 'audio_manager.dart';
import '../analytics_manager.dart';

enum GameState { menu, playing, gameOver, success }

enum Difficulty { easy, normal }

class AirplaneLandingGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late LevelConfig currentLevel;
  GameState state = GameState.menu;
  Airplane? selectedPlane;
  double spawnTimer = 0;
  int score = 0;
  int landings = 0;
  int takeoffs = 0;
  int collisionsCount = 0;
  int nextRunwayIndex = 0;
  double maxSpeedObserved = 0;
  final int maxCollisions = 5; 

  // Difficulty configuration (default easy)
  Difficulty difficulty = Difficulty.easy;
  double planeBaseSpeed = 170.0; 
  double taxiSpeed = 35.0; // slightly faster taxi for excitement

  // Use a fixed virtual coordinate system for consistent layout across orientations
  final Vector2 virtualSize = Vector2(1000, 1000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Setup camera with 1000x1000 fixed resolution
    camera = CameraComponent.withFixedResolution(width: 1000, height: 1000);
    camera.viewfinder.anchor = Anchor.topLeft;

    currentLevel = LevelConfig.allLevels[0];
  }

  @override
  Color backgroundColor() => Colors.black;

  void loadLevel(LevelConfig level) {
    currentLevel = level;
    world.removeAll(world.children);
    world.add(AirportMap(currentLevel));
    
    // Add Gates
    for (final gc in currentLevel.gates) {
      world.add(Gate(gc));
    }

    spawnTimer = 0;
    selectedPlane = null;
  }

  void startGame() {
    state = GameState.playing;
    score = 0;
    landings = 0;
    takeoffs = 0;
    collisionsCount = 0;
    // Set spawnTimer to trigger the first plane after 2.5 seconds
    spawnTimer = _currentSpawnInterval() - 2.5;
    selectedPlane = null;
    maxSpeedObserved = planeBaseSpeed;
    
    AnalyticsManager.logGameStarted(currentLevel.name, difficulty.name);
    AnalyticsManager.logMenuView('GameView');
    
    // Clear all components except map
    final planes = world.children.whereType<Airplane>().toList();
    world.removeAll(planes);
    
    overlays.remove('MainMenu');
    overlays.remove('LevelSelector');
    overlays.remove('GameOver');
    AudioManager.stopCrowdAmbiance();
    overlays.add('HUD');
    AudioManager.playBackground();
    // Stop selection music after a short delay to allow it to be heard during transition
    Future.delayed(const Duration(milliseconds: 1500), () {
      AudioManager.stopSelectionMusic();
    });
  }

  void resetToMenu() {
    state = GameState.menu;
    world.removeAll(world.children);
    selectedPlane = null;
    overlays.clear();
    overlays.add('MainMenu');
  }

  void selectPlane(Airplane plane) {
    selectedPlane?.isSelected = false;
    selectedPlane = plane;
    plane.isSelected = true;
  }

  double elapsedTime = 0;
  @override
  void update(double dt) {
    super.update(dt);
    elapsedTime += dt;
    if (state == GameState.playing) {
      // Dynamic Difficulty: Increase speed by 8 units every 5000 points
      planeBaseSpeed = 170.0 + (score ~/ 5000) * 8.0;
      
      spawnTimer += dt;
      if (spawnTimer > _currentSpawnInterval()) {
        // Higher scores can spawn multiple planes at once
        int spawnCount = 1;
        if (score >= 30000) {
          spawnCount = (Random().nextDouble() < 0.4) ? 3 : 2; // High intensity
        } else if (score >= 20000) {
          spawnCount = (Random().nextDouble() < 0.5) ? 2 : 1;
        } else if (score >= 10000) {
          spawnCount = (Random().nextDouble() < 0.3) ? 2 : 1;
        }

        for (int i = 0; i < spawnCount; i++) {
          // Slight delay between multiple spawns to prevent overlapping sounds
          Future.delayed(Duration(milliseconds: i * 800), () {
            if (state == GameState.playing) world.add(Airplane());
          });
        }
        
        spawnTimer = 0;
      }

      // Track highest speed
      if (planeBaseSpeed > maxSpeedObserved) {
        maxSpeedObserved = planeBaseSpeed;
      }
    }
  }

  double _currentSpawnInterval() {
    // Base starts at 14s
    double interval = 14.0;

    // Milestone-based drops
    if (score >= 30000) {
      interval = 4.0; // Very fast
    } else if (score >= 20000) {
      interval = 6.5;
    } else if (score >= 10000) {
      interval = 9.0;
    } else if (score >= 5000) {
      interval = 11.5;
    }

    // Additional smooth scaling for granular difficulty
    double reduction = (score % 5000 / 5000) * 1.5;
    return max(2.5, interval - reduction);
  }

  Runway getNextRunway() {
    final runway = currentLevel.runways[nextRunwayIndex % currentLevel.runways.length];
    nextRunwayIndex++;
    return runway;
  }

  final List<int> milestones = [1000, 3000, 5000, 7000, 10000, 15000, 20000, 25000, 30000, 40000, 50000, 75000, 100000];
  int _lastMilestoneIdx = -1;

  void addPoints(int points, {bool isLanding = false, bool isTakeoff = false}) {
    score += points;
    if (isLanding) landings++;
    if (isTakeoff) takeoffs++;

    // Check Milestones
    for (int i = 0; i < milestones.length; i++) {
      if (score >= milestones[i] && _lastMilestoneIdx < i) {
        _lastMilestoneIdx = i;
        _triggerCelebration();

        // Special Traffic Alerts
        if (milestones[i] == 10000) {
          AudioManager.announce('Warning: Traffic density increasing.');
        } else if (milestones[i] == 20000) {
          AudioManager.announce('Caution: Heavy airspace congestion reported.');
        } else if (milestones[i] == 30000) {
          AudioManager.announce('Emergency: Maximum traffic load reached. Maintain clearance.');
        }
        break;
      }
    }
  }

  void _triggerCelebration() {
    final random = Random();
    AudioManager.playSfx('celebration.mp3');
    
    // 1. Glittering Stars (Screen Center)
    camera.viewport.add(
      ParticleSystemComponent(
        position: Vector2(virtualSize.x / 2, virtualSize.y / 2),
        particle: Particle.generate(
          count: 50,
          lifespan: 3.0,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(random.nextDouble() * 200 - 100, random.nextDouble() * 200 - 100),
            speed: Vector2(random.nextDouble() * 400 - 200, random.nextDouble() * 400 - 200),
            child: CircleParticle(
              radius: random.nextDouble() * 4 + 1,
              paint: Paint()..color = Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );

    // 2. Celebration Balloons (Floating Up)
    camera.viewport.add(
      ParticleSystemComponent(
        position: Vector2(virtualSize.x / 2, virtualSize.y),
        particle: Particle.generate(
          count: 40,
          lifespan: 5.0,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(random.nextDouble() * 100 - 50, -250),
            speed: Vector2(random.nextDouble() * 200 - 100, -500),
            child: CircleParticle(
              radius: random.nextDouble() * 15 + 10,
              paint: Paint()
                ..color = [
                  Colors.red, Colors.blue, Colors.green, Colors.yellow, 
                  Colors.purple, Colors.orange, Colors.pink, Colors.cyanAccent
                ][random.nextInt(8)].withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  double _lastCollisionTime = 0;

  void onCollisionOccurred() {
    // Prevent double-triggering when two planes collide at once
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (currentTime - _lastCollisionTime < 0.5) return;
    _lastCollisionTime = currentTime;

    collisionsCount++;
    score = (score - 300).clamp(0, 999999); // -300 points
    AudioManager.playSfx('plane_crash.wav');
    AudioManager.vibrate();
    
    if (collisionsCount >= maxCollisions) {
      onGameOver(false);
    }
  }

  void onGameOver(bool success) {
    state = success ? GameState.success : GameState.gameOver;
    overlays.remove('HUD');
    overlays.add('GameOver');
    if (!success) AudioManager.playSfx('collision.mp3');

    AnalyticsManager.logGameOver(
      score: score, 
      landings: landings, 
      takeoffs: takeoffs, 
      airport: currentLevel.name, 
      maxSpeedReached: maxSpeedObserved
    );
    AnalyticsManager.logMenuView('GameOver');
  }
}
