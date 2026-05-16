import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/game.dart';
import '../game/level_config.dart';
import '../game/audio_manager.dart';
import '../persistence_manager.dart';

class LevelSelector extends StatefulWidget {
  final AirplaneLandingGame game;
  const LevelSelector({super.key, required this.game});

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  int totalLandings = 0;
  Map<String, int> bestScores = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    totalLandings = await PersistenceManager.getTotalLandings();
    for (var level in LevelConfig.allLevels) {
      final scores = await PersistenceManager.getHighScores(level.iataCode);
      if (scores.isNotEmpty) {
        bestScores[level.iataCode] = scores.first;
      }
    }
    if (mounted) setState(() {});
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
            child: Column(
              children: [
                FittedBox(
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
                const SizedBox(height: 10),
                Text(
                  'TOTAL LANDINGS: $totalLandings',
                  style: GoogleFonts.inter(
                    color: Colors.cyanAccent,
                    fontSize: isIPad ? 18 : 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
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
                    childAspectRatio: isIPad ? 1.1 : 1.8,
                  ),
                  itemCount: LevelConfig.allLevels.length,
                  itemBuilder: (context, index) {
                    final level = LevelConfig.allLevels[index];
                    final isUnlocked = totalLandings >= level.landingsToUnlock;
                    return _buildLevelCard(context, level, isIPad, isUnlocked);
                  },
                );
              },
            ),
          ),
          TextButton(
            onPressed: () {
              widget.game.resetToMenu();
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

  Widget _buildLevelCard(BuildContext context, LevelConfig level, bool isIPad, bool isUnlocked) {
    final bestScore = bestScores[level.iataCode];

    return GestureDetector(
      onTap: isUnlocked ? () {
        AudioManager.stopCrowdAmbiance();
        AudioManager.playSelectionMusic();
        widget.game.loadLevel(level);
        widget.game.startGame();
      } : () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'LOCK: Reach ${level.landingsToUnlock} total landings to unlock ${level.name}',
              style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isUnlocked ? Colors.cyan.withOpacity(0.5) : Colors.white10, 
            width: 2
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/${level.backgroundImage}'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              isUnlocked ? Colors.black.withOpacity(0.7) : Colors.black.withOpacity(0.9), 
              BlendMode.darken
            ),
          ),
          boxShadow: [
            if (isUnlocked) BoxShadow(color: Colors.cyan.withOpacity(0.1), blurRadius: 20),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent, 
                isUnlocked ? Colors.black.withOpacity(0.8) : Colors.black.withOpacity(0.9)
              ],
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isUnlocked) ...[
                          Icon(Icons.lock_outline, color: Colors.white24, size: isIPad ? 40 : 32),
                          const SizedBox(height: 4),
                          Text(
                            '${level.landingsToUnlock} LANDINGS',
                            style: GoogleFonts.orbitron(
                              color: Colors.white24,
                              fontSize: isIPad ? 12 : 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            level.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: GoogleFonts.orbitron(
                              color: isUnlocked ? Colors.white : Colors.white24, 
                              fontSize: isIPad ? 20 : 16, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1
                            ),
                          ),
                        ),
                        if (isUnlocked) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${level.country.toUpperCase()} (${level.iataCode})',
                            style: GoogleFonts.inter(
                              color: Colors.cyanAccent.withOpacity(0.7), 
                              fontSize: isIPad ? 12 : 11, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 1.5
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (isUnlocked && bestScore != null)
                Positioned(
                  top: 12,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                    ),
                    child: Text(
                      'BEST: $bestScore',
                      style: GoogleFonts.orbitron(
                        color: Colors.yellow,
                        fontSize: isIPad ? 12 : 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ).animate().scale(delay: 100.ms * LevelConfig.allLevels.indexOf(level)),
    );
  }
}
