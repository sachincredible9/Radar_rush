import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'ui/main_menu.dart';
import 'ui/hud.dart';
import 'ui/level_selector.dart';
import 'ui/instructions.dart';
import 'ui/game_over.dart';
import 'game/game.dart';

import 'game/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const GameScreen(),
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
