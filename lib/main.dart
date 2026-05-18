import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/main_menu.dart';
import 'ui/hud.dart';
import 'ui/level_selector.dart';
import 'ui/instructions.dart';
import 'ui/game_over.dart';
import 'game/game.dart';
import 'game/level_config.dart';
import 'core/service_locator.dart';
import 'core/services/audio_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/analytics_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'ui/login_screen.dart';

bool _isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Phase 1 & 2: Resource, Data & DI Optimization
  await setupServiceLocator();
  await LevelConfig.loadLevels();

  try {
    await Firebase.initializeApp();
    _isFirebaseInitialized = true;
    await getIt<AnalyticsService>().init();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  await getIt<AudioService>().init();
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: _isFirebaseInitialized 
        ? StreamBuilder(
            stream: getIt<AuthService>().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(child: CircularProgressIndicator(color: Colors.cyan)),
                );
              }
              
              if (snapshot.hasData) {
                return const GameScreen();
              }
              
              return const LoginScreen();
            },
          )
        : const GameScreen(), // Fallback to GameScreen if Firebase is offline
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late AirplaneLandingGame game;

  @override
  void initState() {
    super.initState();
    game = AirplaneLandingGame();
    
    // Log initial app launch metrics
    getIt<AnalyticsService>().logAppLaunch();
    
    // Log screen details after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final analytics = getIt<AnalyticsService>();
      analytics.logScreenDetails(size);
      analytics.logMenuView('MainMenu');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<AirplaneLandingGame>(
        game: game,
        overlayBuilderMap: {
          'MainMenu': (context, game) => MainMenu(game: game),
          'HUD': (context, game) => HUD(game: game),
          'LevelSelector': (context, game) => LevelSelector(game: game),
          'Instructions': (context, game) => InstructionsOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}
