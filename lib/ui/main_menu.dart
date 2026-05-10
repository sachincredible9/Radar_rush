import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/game.dart';

import '../game/audio_manager.dart';
import 'package:radar_rush/auth_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MainMenu extends StatefulWidget {
  final AirplaneLandingGame game;
  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    AudioManager.playCrowdAmbiance();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isIPad = screenWidth > 800;

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyan, width: 3),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/app_icon.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.cyan.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
              ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.5, 0.5)),
              const SizedBox(height: 30),
              Text(
                'RADAR RUSH',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: isIPad ? 50 : 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(duration: 1.seconds).slideY(begin: -0.5),
              const SizedBox(height: 10),
              Text(
                'GLOBAL ATC MANAGEMENT',
                style: GoogleFonts.inter(
                  color: Colors.cyan,
                  fontSize: 14,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => widget.game.overlays.add('LevelSelector'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.cyan, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  'SELECT RUNWAY',
                  style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
                ),
              ).animate().scale(delay: 1.seconds).shimmer(duration: 2.seconds),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  AudioManager.stopCrowdAmbiance();
                  widget.game.overlays.add('Instructions');
                },
                child: Text(
                  'FLIGHT MANUAL & INFO',
                  style: GoogleFonts.inter(color: Colors.cyan.withOpacity(0.7), fontSize: 12, letterSpacing: 2),
                ),
              ).animate().fadeIn(delay: 1.5.seconds),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => AuthManager.signOut(),
                child: Text(
                  'SIGN OUT',
                  style: GoogleFonts.inter(color: Colors.redAccent.withOpacity(0.5), fontSize: 10, letterSpacing: 1),
                ),
              ).animate().fadeIn(delay: 2.seconds),
            ],
          ),
        ),
        // Mute Button at Top Right
        Positioned(
          top: isIPad ? 60 : 40,
          right: isIPad ? 40 : 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.cyan.withOpacity(0.5)),
            ),
            child: IconButton(
              icon: Icon(
                AudioManager.isMuted ? Icons.volume_off : Icons.volume_up,
                color: AudioManager.isMuted ? Colors.redAccent : Colors.cyanAccent,
                size: isIPad ? 32 : 24,
              ),
              onPressed: () {
                AudioManager.toggleMute();
                if (!AudioManager.isMuted) {
                  AudioManager.playCrowdAmbiance();
                }
                setState(() {});
              },
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
        
        // Version Tag at Bottom Left
        Positioned(
          bottom: 10,
          left: 10,
          child: Text(
            _appVersion,
            style: GoogleFonts.inter(color: Colors.white24, fontSize: 10, letterSpacing: 1),
          ),
        ),
      ],
    );
  }
}
