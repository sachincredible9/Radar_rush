import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/game.dart';

class GameOverOverlay extends StatelessWidget {
  final AirplaneLandingGame game;
  const GameOverOverlay({super.key, required this.game});

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
              
              _buildStatRow('TOTAL SCORE', '${game.score}', Colors.yellow, isIPad),
              _buildStatRow('SUCCESSFUL LANDINGS', '${game.landings}', Colors.orangeAccent, isIPad),
              _buildStatRow('SUCCESSFUL TAKEOFFS', '${game.takeoffs}', Colors.greenAccent, isIPad),
              _buildStatRow('INCIDENTS', '${game.collisionsCount}', Colors.red, isIPad),

              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => game.startGame(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.withOpacity(0.2),
                      side: const BorderSide(color: Colors.greenAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('RETRY', style: GoogleFonts.orbitron(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => game.resetToMenu(),
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

  Widget _buildStatRow(String label, String value, Color color, bool isIPad) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: isIPad ? 16 : 12, fontWeight: FontWeight.bold))),
          Text(value, style: GoogleFonts.orbitron(color: color, fontSize: isIPad ? 24 : 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
