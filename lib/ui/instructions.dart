import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game.dart';
import '../core/service_locator.dart';
import '../core/services/audio_service.dart';

class InstructionsOverlay extends StatefulWidget {
  final AirplaneLandingGame game;
  const InstructionsOverlay({super.key, required this.game});

  @override
  State<InstructionsOverlay> createState() => _InstructionsOverlayState();
}

class _InstructionsOverlayState extends State<InstructionsOverlay> {
  String? _playingLabel;

  @override
  void initState() {
    super.initState();
    // Play selection sound once when manual opens
    getIt<AudioService>().playSelectionMusic();
  }

  void _dismissManual() {
    getIt<AudioService>().resumeAll(); // Resume all audio (bgm, sfx)
    widget.game.resumeEngine(); // Resume gameplay loop
    widget.game.overlays.remove('Instructions');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isIPad = screenWidth > 800;

    return Container(
      color: Colors.black.withOpacity(0.95),
      padding: EdgeInsets.fromLTRB(
        isIPad ? 60 : 32, 
        isIPad ? 60 : 10, // Reduced top padding to clear notch via SafeArea only
        isIPad ? 60 : 32, 
        isIPad ? 60 : 32
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isIPad ? 900 : 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'FLIGHT MANUAL',
                        style: GoogleFonts.orbitron(
                          color: Colors.cyan,
                          fontSize: isIPad ? 42 : 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: isIPad ? 40 : 30),
                      onPressed: _dismissManual,
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 48, thickness: 2),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSection('STATUS INDICATORS', isIPad, [
                        _buildRow(Icons.airplanemode_active, Colors.orange, 'WAITING TAXI', 'Aircraft has landed and is waiting for taxi instructions.', isIPad),
                        _buildRow(Icons.local_taxi, Colors.cyan, 'TAXIING', 'Aircraft is moving towards the apron zone.', isIPad),
                        _buildRow(Icons.drag_indicator, Colors.redAccent, 'READY TO PARK', 'Aircraft is at the apron. DRAG to the RED gate to dock.', isIPad),
                        _buildRow(Icons.check_circle, Colors.greenAccent, 'AT GATE / READY', 'Aircraft is parked. Needs 4s servicing before takeoff.', isIPad),
                        _buildRow(Icons.loop, Colors.purpleAccent, 'HOLDING', 'Aircraft is orbiting the airport.', isIPad),
                      ]),
                      const SizedBox(height: 40),
                      _buildSection('POINT MECHANISM', isIPad, [
                        _buildPointRow('500 PTS', 'Successful Touchdown on runway.', isIPad),
                        _buildPointRow('500 PTS', 'Safely parking at the terminal gate.', isIPad),
                        _buildPointRow('1500 PTS', 'Successful Takeoff and Departure.', isIPad),
                        _buildPointRow('-300 PTS', 'Penalty for near-miss or minor collision.', isIPad),
                      ]),
                      const SizedBox(height: 40),
                      _buildSection('ATC COMMANDS', isIPad, [
                        _buildCmdRow('LAND', 'Clears plane to land on the nearest runway.', isIPad),
                        _buildCmdRow('TAXI', 'Directs landed planes to the apron for parking.', isIPad),
                        _buildCmdRow('TAKEOFF', 'Clears parked OR landed planes for immediate departure.', isIPad),
                        _buildCmdRow('DRAG', 'Manual: Drag plane from apron to the highlighted RED gate.', isIPad),
                      ]),
                      const SizedBox(height: 40),
                      _buildSection('AUDIO DICTIONARY', isIPad, [
                        _buildAudioRow(Icons.radar, 'RADAR PING', 'New aircraft contact detected in your sector.', () => getIt<AudioService>().playSfx('radar_ping.mp3'), () => {}, isIPad),
                        _buildAudioRow(Icons.flight_takeoff, 'TAKEOFF ROAR', 'Aircraft has initiated departure engine power.', () => getIt<AudioService>().playTakeoffSound(), () => getIt<AudioService>().stopTakeoffSound(), isIPad),
                        _buildAudioRow(Icons.people, 'AIRPORT CROWD', 'Ambient terminal background atmosphere.', () => getIt<AudioService>().playCrowdAmbiance(), () => getIt<AudioService>().stopCrowdAmbiance(), isIPad),
                        _buildAudioRow(Icons.warning, 'CRASH IMPACT', 'Critical alert for mid-air collision.', () => getIt<AudioService>().playSfx('plane_crash.wav'), () => {}, isIPad),
                      ]),
                      const SizedBox(height: 40),
                      _buildSection('SYSTEM SETTINGS', isIPad, [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Icon(Icons.vibration, color: Colors.cyanAccent, size: isIPad ? 32 : 24),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('HAPTIC FEEDBACK', style: GoogleFonts.inter(color: Colors.white, fontSize: isIPad ? 20 : 16, fontWeight: FontWeight.bold)),
                                    Text('Vibrate device on collisions and critical alerts.', style: GoogleFonts.inter(color: Colors.white70, fontSize: isIPad ? 18 : 14)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: getIt<AudioService>().isVibrationEnabled,
                                activeColor: Colors.cyanAccent,
                                onChanged: (val) {
                                  setState(() {
                                    getIt<AudioService>().isVibrationEnabled = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _dismissManual,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.withOpacity(0.2),
                    side: const BorderSide(color: Colors.cyan, width: 2),
                    padding: EdgeInsets.symmetric(horizontal: isIPad ? 80 : 50, vertical: isIPad ? 25 : 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text('DISMISS MANUAL', style: GoogleFonts.orbitron(color: Colors.white, fontSize: isIPad ? 24 : 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  bool _isProcessing = false;

  Widget _buildAudioRow(IconData icon, String label, String desc, VoidCallback onPlay, VoidCallback onStop, bool isIPad) {
    bool isPlaying = _playingLabel == label;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              if (_isProcessing) return;
              _isProcessing = true;

              if (isPlaying) {
                onStop();
                setState(() => _playingLabel = null);
              } else {
                if (_playingLabel != null) {
                   getIt<AudioService>().stopAllSfx();
                }
                onPlay();
                setState(() => _playingLabel = label);
                
                if (label != 'AIRPORT CROWD') {
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted && _playingLabel == label) {
                      setState(() => _playingLabel = null);
                    }
                  });
                }
              }
              
              await Future.delayed(const Duration(milliseconds: 300));
              _isProcessing = false;
            },
            icon: Icon(
              isPlaying ? Icons.stop_circle : Icons.play_circle_fill, 
              color: isPlaying ? Colors.redAccent : Colors.cyanAccent, 
              size: isIPad ? 40 : 32
            ),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: isIPad ? 18 : 14, fontWeight: FontWeight.bold)),
                Text(desc, style: GoogleFonts.inter(color: Colors.white70, fontSize: isIPad ? 16 : 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, bool isIPad, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: isIPad ? 24 : 18, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildRow(IconData icon, Color color, String label, String desc, bool isIPad) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: isIPad ? 32 : 24),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(color: color, fontSize: isIPad ? 20 : 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.inter(color: Colors.white70, fontSize: isIPad ? 18 : 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointRow(String pts, String desc, bool isIPad) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          SizedBox(
            width: isIPad ? 150 : 100,
            child: Text(pts, style: GoogleFonts.orbitron(color: Colors.yellow, fontSize: isIPad ? 20 : 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 20),
          Expanded(child: Text(desc, style: GoogleFonts.inter(color: Colors.white, fontSize: isIPad ? 18 : 14))),
        ],
      ),
    );
  }

  Widget _buildCmdRow(String cmd, String desc, bool isIPad) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: isIPad ? 140 : 100,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white12,
              border: Border.all(color: Colors.white24, width: 2), 
              borderRadius: BorderRadius.circular(8)
            ),
            child: Text(cmd, textAlign: TextAlign.center, style: GoogleFonts.orbitron(color: Colors.white, fontSize: isIPad ? 18 : 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 20),
          Expanded(child: Text(desc, style: GoogleFonts.inter(color: Colors.white, fontSize: isIPad ? 18 : 14))),
        ],
      ),
    );
  }
}
