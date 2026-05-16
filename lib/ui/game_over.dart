import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/game.dart';
import '../game/level_config.dart';
import '../persistence_manager.dart';

class GameOverOverlay extends StatefulWidget {
  final AirplaneLandingGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  int? bestScore;
  bool levelUnlocked = false;

  @override
  void initState() {
    super.initState();
    _checkProgress();
  }

  Future<void> _checkProgress() async {
    final scores = await PersistenceManager.getHighScores(widget.game.currentLevel.iataCode);
    if (scores.isNotEmpty) {
      bestScore = scores.first;
    }
    
    final totalLandings = await PersistenceManager.getTotalLandings();
    // Check if any NEW level was unlocked in this session
    // (This is a bit simplified, but checks if total landings just crossed a threshold)
    for (var level in LevelConfig.allLevels) {
      if (totalLandings >= level.landingsToUnlock && 
          totalLandings - widget.game.landings < level.landingsToUnlock) {
        levelUnlocked = true;
        break;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isIPad = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 3),
            boxShadow: [
              BoxShadow(color: Colors.redAccent.withOpacity(0.2), blurRadius: 30, spreadRadius: 10),
            ],
          ),
          constraints: BoxConstraints(maxWidth: isIPad ? 600 : 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TERMINAL CLOSED',
                style: GoogleFonts.orbitron(
                  color: Colors.redAccent,
                  fontSize: isIPad ? 40 : 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ).animate().shimmer(duration: 2.seconds),
              const SizedBox(height: 10),
              Text(
                'MISSION STATISTICS',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: isIPad ? 18 : 14, letterSpacing: 2),
              ),
              const Divider(color: Colors.white24, height: 40, thickness: 2),
              
              if (levelUnlocked)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.cyanAccent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.cyanAccent),
                      const SizedBox(width: 10),
                      Text(
                        'NEW AIRPORT UNLOCKED!',
                        style: GoogleFonts.orbitron(
                          color: Colors.cyanAccent,
                          fontSize: isIPad ? 16 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(delay: 500.ms).shimmer(),

              _buildStatRow('TOTAL SCORE', '${widget.game.score}', Colors.yellow, isIPad, bestValue: bestScore),
              _buildStatRow('SUCCESSFUL LANDINGS', '${widget.game.landings}', Colors.orangeAccent, isIPad),
              _buildStatRow('SUCCESSFUL TAKEOFFS', '${widget.game.takeoffs}', Colors.greenAccent, isIPad),
              _buildStatRow('INCIDENTS', '${widget.game.collisionsCount}', Colors.red, isIPad),

              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => widget.game.startGame(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.withOpacity(0.2),
                      side: const BorderSide(color: Colors.greenAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('RETRY', style: GoogleFonts.orbitron(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => widget.game.resetToMenu(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('MENU', style: GoogleFonts.orbitron(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color, bool isIPad, {int? bestValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: isIPad ? 16 : 12, fontWeight: FontWeight.bold))),
              Text(value, style: GoogleFonts.orbitron(color: color, fontSize: isIPad ? 24 : 18, fontWeight: FontWeight.bold)),
            ],
          ),
          if (bestValue != null && label == 'TOTAL SCORE')
            Text(
              'BEST: $bestValue',
              style: GoogleFonts.orbitron(
                color: Colors.yellow.withOpacity(0.5),
                fontSize: isIPad ? 12 : 9,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
