import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/main_menu.dart';
import 'ui/hud.dart';
import 'ui/level_selector.dart';
import 'ui/instructions.dart';
import 'ui/game_over.dart';
import 'game/game.dart';
import 'game/audio_manager.dart';
import 'analytics_manager.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:radar_rush/auth_manager.dart';
import 'ui/login_screen.dart';

bool _isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    _isFirebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  await AnalyticsManager.init();
  await AudioManager.init();
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
            stream: AuthManager.authStateChanges,
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
        : Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 20),
                  Text(
                    'FIREBASE OFFLINE',
                    style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Check GoogleService-Info.plist in Xcode',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
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
    AnalyticsManager.logAppLaunch();
    
    // Log screen details after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      AnalyticsManager.logScreenDetails(size);
      AnalyticsManager.logMenuView('MainMenu');
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
