import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/game.dart';
import '../core/service_locator.dart';
import '../core/services/audio_service.dart';
import '../core/services/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:in_app_review/in_app_review.dart';

class MainMenu extends StatefulWidget {
  final AirplaneLandingGame game;
  final VoidCallback? onSignOut;
  const MainMenu({super.key, required this.game, this.onSignOut});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String _appVersion = '';
  final InAppReview _inAppReview = InAppReview.instance;

  Future<void> _requestReview() async {
    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
    getIt<AudioService>().playCrowdAmbiance();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'DELETE ACCOUNT?',
            style: GoogleFonts.orbitron(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone and will permanently remove your progress and data.',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL', style: GoogleFonts.inter(color: Colors.white54)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('DELETE', style: GoogleFonts.inter(color: Colors.redAccent)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await getIt<AuthService>().deleteAccount();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete account. Please re-authenticate and try again.', style: GoogleFonts.inter()),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isIPad = screenWidth > 800;

    return Stack(
      children: [
        // Static Background to prevent ghosting
        Positioned.fill(
          child: Image.asset(
            'assets/images/airport_london.jpg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.85), // Darkened for better contrast
            colorBlendMode: BlendMode.darken,
          ),
        ),
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
                  fontSize: isIPad ? 18 : 14,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => widget.game.overlays.add('LevelSelector'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan.withOpacity(0.15),
                  side: const BorderSide(color: Colors.cyan, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: isIPad ? 60 : 40, vertical: isIPad ? 30 : 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Text(
                  'SELECT RUNWAY',
                  style: GoogleFonts.orbitron(color: Colors.white, fontSize: isIPad ? 24 : 18, fontWeight: FontWeight.bold),
                ),
              ).animate().scale(delay: 1.seconds).shimmer(duration: 2.seconds),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  getIt<AudioService>().stopCrowdAmbiance();
                  widget.game.overlays.add('Instructions');
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  side: BorderSide(color: Colors.cyan.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(horizontal: isIPad ? 36 : 24, vertical: isIPad ? 18 : 12),
                ),
                child: Text(
                  'FLIGHT MANUAL & INFO',
                  style: GoogleFonts.inter(color: Colors.cyanAccent, fontSize: isIPad ? 16 : 12, letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
              ).animate().fadeIn(delay: 1.5.seconds),

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
                getIt<AudioService>().isMuted ? Icons.volume_off : Icons.volume_up,
                color: getIt<AudioService>().isMuted ? Colors.redAccent : Colors.cyanAccent,
                size: isIPad ? 32 : 24,
              ),
              onPressed: () {
                getIt<AudioService>().toggleMute();
                if (!getIt<AudioService>().isMuted) {
                  getIt<AudioService>().playCrowdAmbiance();
                }
                setState(() {});
              },
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
        
        // Hamburger Menu at Top Left
        Positioned(
          top: isIPad ? 60 : 40,
          left: isIPad ? 40 : 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.cyan.withOpacity(0.5)),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: Colors.cyanAccent, size: isIPad ? 32 : 24),
              color: Colors.grey[900],
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) {
                if (value == 'review') {
                  _requestReview();
                } else if (value == 'signout') {
                  widget.onSignOut?.call();
                  getIt<AuthService>().signOut();
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context);
                }
              },
              itemBuilder: (context) {
                final bool isGuest = getIt<AuthService>().currentUser == null;
                return [
                  PopupMenuItem(
                    enabled: false,
                    child: Text('Version $_appVersion', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'review',
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 10),
                        Text('Rate the App', style: GoogleFonts.inter(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'signout',
                    child: Row(
                      children: [
                        Icon(isGuest ? Icons.login : Icons.logout, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(isGuest ? 'Login / Register' : 'Sign Out', style: GoogleFonts.inter(color: Colors.white)),
                      ],
                    ),
                  ),
                  if (!isGuest)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Text('Delete Account', style: GoogleFonts.inter(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                ];
              },
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }
}
