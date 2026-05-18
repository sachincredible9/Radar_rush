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

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/login_screen.dart';

bool _isFirebaseInitialized = false;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Phase 1: Initialize Firebase first so FirebaseAuth references inside service constructors are valid
  try {
    await Firebase.initializeApp();
    _isFirebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Phase 2: DI and Resource Configurations
  await setupServiceLocator();
  await LevelConfig.loadLevels();

  if (_isFirebaseInitialized) {
    try {
      await getIt<AnalyticsService>().init();
    } catch (e) {
      debugPrint('Analytics initialization failed: $e');
    }
  }
  
  await getIt<AudioService>().init();
  FlutterNativeSplash.remove();
  runApp(const GameApp());
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  bool _bypassAuth = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: _bypassAuth 
        ? const GameScreen()
        : StreamBuilder(
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
              
              return LoginScreen(
                onPlayAsGuest: () {
                  setState(() {
                    _bypassAuth = true;
                  });
                },
              );
            },
          ),
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
