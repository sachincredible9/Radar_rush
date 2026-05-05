import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/game.dart';
import '../game/level_config.dart';

import '../game/audio_manager.dart';

class LevelSelector extends StatefulWidget {
  final AirplaneLandingGame game;
  const LevelSelector({super.key, required this.game});

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // We don't stop it here anymore so the tap sound can finish playing during transition
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isIPad = screenWidth > 800;

    return Container(
      color: Colors.black.withOpacity(0.95),
      child: Column(
        children: [
          SizedBox(height: isIPad ? 80 : 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'SELECT AIRPORT',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: isIPad ? 48 : 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: isIPad ? 8 : 4,
                ),
              ).animate().fadeIn().slideY(begin: -0.5),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: isIPad ? 100 : 30, vertical: 20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isIPad ? 3 : (constraints.maxWidth < 600 ? 1 : 2),
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 30,
                    childAspectRatio: isIPad ? 1.6 : 2.0,
                  ),
                  itemCount: LevelConfig.allLevels.length,
                  itemBuilder: (context, index) {
                    final level = LevelConfig.allLevels[index];
                    return _buildLevelCard(context, level, isIPad);
                  },
                );
              },
            ),
          ),
          TextButton(
            onPressed: () {
              widget.game.overlays.remove('LevelSelector');
              widget.game.overlays.add('MainMenu');
              AudioManager.stopSelectionMusic();
            },
            child: Text(
              'BACK TO MAIN MENU', 
              style: GoogleFonts.orbitron(
                color: Colors.white54, 
                fontSize: isIPad ? 20 : 14, 
                letterSpacing: 2
              )
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, LevelConfig level, bool isIPad) {
    return GestureDetector(
      onTap: () {
        AudioManager.stopCrowdAmbiance();
        AudioManager.playSelectionMusic(); // Play once on tap
        widget.game.loadLevel(level);
        widget.game.startGame();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 2),
          image: DecorationImage(
            image: AssetImage('assets/images/${level.backgroundImage}'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(color: Colors.cyan.withOpacity(0.1), blurRadius: 20),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  level.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    color: Colors.white, 
                    fontSize: isIPad ? 22 : 16, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${level.country.toUpperCase()} (${level.iataCode})',
                style: GoogleFonts.inter(
                  color: Colors.cyanAccent, 
                  fontSize: isIPad ? 14 : 11, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 2
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(delay: 100.ms * LevelConfig.allLevels.indexOf(level)),
    );
  }
}
