import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/game.dart';
import '../game/components/airplane.dart';
import '../game/audio_manager.dart';

class HUD extends StatefulWidget {
  final AirplaneLandingGame game;
  const HUD({super.key, required this.game});

  @override
  State<HUD> createState() => _HUDState();
}

class _HUDState extends State<HUD> {
  Offset panelOffset = const Offset(30, 600); 
  double panelWidth = 320;
  double panelHeight = 150;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final isIPad = size.width > 800;
      final isSmallPhone = size.width < 400;
      final isShortScreen = size.height < 700;
      
      setState(() {
        panelWidth = isIPad ? 580 : (isSmallPhone ? size.width * 0.9 : 400);
        panelHeight = isIPad ? 260 : (isShortScreen ? 140 : 180);
        
        // Position panel at the bottom with safe margins, adjusting for height
        double bottomMargin = isIPad ? 650 : (isShortScreen ? 280 : 380);
        panelOffset = Offset(
          (size.width - panelWidth) / 2, 
          (size.height - bottomMargin).clamp(100.0, size.height - 200.0)
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final paddingTop = MediaQuery.of(context).padding.top;
    
    final isIPad = screenWidth > 800 || screenHeight > 1000;
    final isShortScreen = screenHeight < 700;
    
    // Proportional font sizing
    final double baseFontSize = isIPad ? 22 : (isShortScreen ? 13 : 15);
    final double headerFontSize = isIPad ? 32 : (isShortScreen ? 18 : 22);

    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        final selectedPlane = widget.game.selectedPlane;
        final isPaused = widget.game.paused;

        return Stack(
          children: [
            // Top Control Bar(s)
            Positioned(
              top: isIPad ? 60 : (isShortScreen ? max(10.0, paddingTop) : max(45.0, paddingTop + 10)), 
              left: isIPad ? 40 : 8,
              right: isIPad ? 40 : 8,
              child: isIPad 
                ? _buildUnifiedTopBar(selectedPlane, isPaused, baseFontSize, headerFontSize, isIPad)
                : Column(
                    children: [
                      _buildMobileStatsBar(selectedPlane, baseFontSize, headerFontSize, isPaused, isShortScreen),
                      SizedBox(height: isShortScreen ? 6 : 12),
                      _buildMobileControlsBar(isPaused, isIPad, isShortScreen),
                    ],
                  ),
            ),

            Positioned(
              bottom: isShortScreen ? 8 : 30,
              left: isShortScreen ? 8 : 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                ),
                child: IconButton(
                  padding: EdgeInsets.all(isShortScreen ? 4 : 8),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.info_outline, color: Colors.white, size: isIPad ? 40 : (isShortScreen ? 18 : 28)),
                  onPressed: () {
                    widget.game.pauseEngine();
                    AudioManager.pauseAll();
                    widget.game.overlays.add('Instructions');
                  },
                ),
              ),
            ),

            Positioned(
              left: panelOffset.dx,
              top: panelOffset.dy,
              child: Stack(
                children: [
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        panelOffset += details.delta;
                      });
                    },
                    child: _buildCommandPanel(selectedPlane, isIPad, headerFontSize, baseFontSize, panelWidth, panelHeight, isShortScreen),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          panelWidth = (panelWidth + details.delta.dx).clamp(250.0, 800.0);
                          panelHeight = (panelHeight + details.delta.dy).clamp(isIPad ? 180.0 : (isShortScreen ? 120.0 : 160.0), 500.0);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(20)),
                        ),
                        child: const Icon(Icons.south_east, size: 20, color: Colors.cyanAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUnifiedTopBar(Airplane? selectedPlane, bool isPaused, double baseFontSize, double headerFontSize, bool isIPad) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth - 60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: _topBarDecoration(),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedPlane != null) ...[
                  _buildPlaneInfo(selectedPlane, headerFontSize, baseFontSize),
                  const SizedBox(width: 16),
                  _topBarDivider(isIPad),
                  const SizedBox(width: 16),
                  _topBarStatusItem(
                    'SPD', 
                    '${selectedPlane.speed.toInt()}', 
                    Colors.yellow, 
                    baseFontSize,
                    onPlus: () => selectedPlane.command('FAST'),
                    onMinus: () => selectedPlane.command('SLOW'),
                  ),
                  const SizedBox(width: 12),
                  _topBarStatusItem('HDG', '${(selectedPlane.angle * 180 / 3.14).toInt().abs()}°', Colors.cyan, baseFontSize),
                  const SizedBox(width: 16),
                  _topBarDivider(isIPad),
                  const SizedBox(width: 16),
                ],
                _buildScoreAndLives(baseFontSize, isIPad),
                const SizedBox(width: 20),
                _buildActionButtonsGroup(isPaused, isIPad),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileStatsBar(Airplane? selectedPlane, double baseFontSize, double headerFontSize, bool isPaused, bool isShortScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final bool isVeryNarrow = availableWidth < 360;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: isShortScreen ? 8 : 12, vertical: isShortScreen ? 6 : 10),
          decoration: _topBarDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section: Plane Info & Telemetry (Unified Scaling)
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedPlane != null) ...[
                        _buildPlaneInfo(selectedPlane, headerFontSize, baseFontSize),
                        const SizedBox(width: 8),
                        _topBarDivider(false),
                        const SizedBox(width: 8),
                        
                        // Telemetry Group
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _topBarStatusItem(
                              'SPD', 
                              '${selectedPlane.speed.toInt()}', 
                              Colors.yellow, 
                              isShortScreen ? baseFontSize * 0.9 : baseFontSize,
                              onPlus: () => selectedPlane.command('FAST'),
                              onMinus: () => selectedPlane.command('SLOW'),
                            ),
                            const SizedBox(width: 12),
                            _topBarStatusItem(
                              'HDG', 
                              '${(selectedPlane.angle * 180 / 3.14).toInt().abs()}°', 
                              Colors.cyan, 
                              isShortScreen ? baseFontSize * 0.9 : baseFontSize
                            ),
                          ],
                        ),
                      ] else
                        Text('RADAR ACTIVE', style: GoogleFonts.orbitron(color: Colors.cyan, fontSize: baseFontSize, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 8), // Safety spacer
              
              // Right Section: Score & Lives
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: _buildScoreAndLives(baseFontSize, false),
                ),
              ),
            ],
          ),
        );
      }
    );
  }



  Widget _buildMobileControlsBar(bool isPaused, bool isIPad, bool isShortScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isShortScreen ? 12 : 20, vertical: 4),
      decoration: _topBarDecoration(opacity: 0.7),
      child: _buildActionButtonsGroup(isPaused, false),
    );
  }

  BoxDecoration _topBarDecoration({double opacity = 0.85}) {
    return BoxDecoration(
      color: Colors.black.withOpacity(opacity),
      borderRadius: BorderRadius.circular(40),
      border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 2),
      boxShadow: [
        BoxShadow(color: Colors.cyan.withOpacity(0.2), blurRadius: 15),
      ],
    );
  }

  Widget _buildPlaneInfo(Airplane plane, double headerFontSize, double baseFontSize) {
    final isShortScreen = MediaQuery.of(context).size.height < 700;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            plane.flightNumber,
            style: GoogleFonts.orbitron(
              color: Colors.redAccent, 
              fontSize: isShortScreen ? headerFontSize * 0.7 : headerFontSize * 0.85, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Text(
          plane.state.name.toUpperCase(),
          style: GoogleFonts.inter(
            color: Colors.white54, 
            fontSize: isShortScreen ? baseFontSize * 0.55 : baseFontSize * 0.65, 
            letterSpacing: 1
          ),
        ),
      ],
    );
  }

  Widget _buildScoreAndLives(double baseFontSize, bool isIPad) {
    final isShortScreen = MediaQuery.of(context).size.height < 700;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SCORE: ${widget.game.score}',
            style: GoogleFonts.orbitron(
              color: Colors.yellow, 
              fontSize: isShortScreen ? baseFontSize * 0.85 : baseFontSize, 
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(width: isShortScreen ? 6 : 10),
          _topBarDivider(isIPad),
          SizedBox(width: isShortScreen ? 6 : 10),
          Text(
            'LIVES: ${widget.game.maxCollisions - widget.game.collisionsCount}',
            style: GoogleFonts.orbitron(
              color: (widget.game.maxCollisions - widget.game.collisionsCount) <= 1 ? Colors.red : Colors.greenAccent,
              fontSize: isShortScreen ? baseFontSize * 0.85 : baseFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsGroup(bool isPaused, bool isIPad) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactActionBtn(
          isPaused ? Icons.play_arrow : Icons.pause,
          isPaused ? Colors.greenAccent : Colors.white,
          () {
            if (widget.game.paused) {
              widget.game.resumeEngine();
            } else {
              widget.game.pauseEngine();
              AudioManager.stopVoice();
            }
            setState(() {});
          },
          isIPad
        ),
        const SizedBox(width: 4),
        _buildCompactActionBtn(
          AudioManager.isMuted ? Icons.volume_off : Icons.volume_up,
          AudioManager.isMuted ? Colors.red : Colors.cyanAccent,
          () {
            AudioManager.toggleMute();
            if (!AudioManager.isMuted) {
              AudioManager.playRadarBackground();
            }
            setState(() {});
          },
          isIPad
        ),
        const SizedBox(width: 8),
        _buildCompactActionBtn(
          AudioManager.isVibrationEnabled ? Icons.vibration : Icons.do_not_disturb,
          AudioManager.isVibrationEnabled ? Colors.greenAccent : Colors.redAccent,
          () => setState(() => AudioManager.toggleVibration()),
          isIPad
        ),
        const SizedBox(width: 8),
        _buildCompactActionBtn(
          Icons.exit_to_app,
          Colors.orangeAccent,
          () => widget.game.backToLevelSelector(),
          isIPad
        ),
      ],
    );
  }

  Widget _topBarDivider(bool isIPad) {
    return Container(
      height: isIPad ? 30 : 20,
      width: 1,
      color: Colors.white12,
    );
  }

  Widget _buildCompactActionBtn(IconData icon, Color color, VoidCallback onPressed, bool isIPad) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: color, size: isIPad ? 32 : 22),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _topBarStatusItem(String label, String value, Color color, double fontSize, {VoidCallback? onPlus, VoidCallback? onMinus}) {
    final isShortScreen = MediaQuery.of(context).size.height < 700;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: isShortScreen ? fontSize * 0.6 : fontSize * 0.7, fontWeight: FontWeight.bold)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onMinus != null) 
              IconButton(
                icon: Icon(Icons.remove, color: color, size: isShortScreen ? 14 : 16),
                onPressed: onMinus,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            Text(value, style: GoogleFonts.orbitron(color: color, fontSize: fontSize, fontWeight: FontWeight.bold)),
            if (onPlus != null) 
              IconButton(
                icon: Icon(Icons.add, color: color, size: isShortScreen ? 14 : 16),
                onPressed: onPlus,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommandPanel(Airplane? plane, bool isIPad, double headerFontSize, double baseFontSize, double width, double height, bool isShortScreen) {
    return Container(
      width: width, 
      height: height,
      padding: EdgeInsets.all(isIPad ? 20 : (isShortScreen ? 8 : 12)),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (plane != null) ...[
                  // LEFT: Turn Controls (Vertical)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (plane.state != PlaneState.atGate && plane.state != PlaneState.departed) ...[
                          _buildIconButton(Icons.rotate_left, Colors.cyanAccent, () => plane.command('TURN_L'), isIPad),
                          const SizedBox(height: 10),
                          _buildIconButton(Icons.rotate_right, Colors.cyanAccent, () => plane.command('TURN_R'), isIPad),
                        ],
                      ],
                    ),
                  ),
                  
                  // CENTER: Main Actions
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Wrap(
                            spacing: isIPad ? 12 : 8,
                            runSpacing: isIPad ? 12 : 8,
                            alignment: WrapAlignment.center,
                            children: [
                              if (plane.state == PlaneState.enRoute || plane.state == PlaneState.hold)
                                _buildActionBtn('LAND', Icons.flight_land, Colors.orange, () => plane.command('LAND'), isIPad),
                              if (plane.state == PlaneState.enRoute || plane.state == PlaneState.landing)
                                _buildActionBtn('HOLD', Icons.loop, Colors.purpleAccent, () => plane.command('HOLD'), isIPad),
                              if (plane.state == PlaneState.landed)
                                _buildActionBtn('TAXI', Icons.local_taxi, Colors.cyan, () => plane.command('TAXI'), isIPad),
                              if (plane.state == PlaneState.atGate || (plane.state == PlaneState.taxiing && plane.speed == 0) || plane.state == PlaneState.landed)
                                _buildActionBtn('TAKEOFF', Icons.flight_takeoff, Colors.greenAccent, () => plane.command('TAKEOFF'), isIPad),
                              if (plane.state == PlaneState.taxiing && plane.speed > 0)
                                _buildActionBtn('STOP', Icons.stop_circle, Colors.redAccent, () => plane.command('STOP'), isIPad),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // RIGHT: Speed Controls (Vertical)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (plane.state != PlaneState.atGate && plane.state != PlaneState.departed) ...[
                          _buildIconButton(Icons.add_circle_outline, Colors.blue, () => plane.command('FAST'), isIPad),
                          const SizedBox(height: 4),
                          _buildIconButton(Icons.remove_circle_outline, Colors.red, () => plane.command('SLOW'), isIPad),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'AWAITING AIRCRAFT...',
                            style: GoogleFonts.orbitron(color: Colors.redAccent, fontSize: baseFontSize, fontWeight: FontWeight.bold, letterSpacing: 2),
                          ).animate(onPlay: (controller) => controller.repeat()).fadeIn(duration: 600.ms).then(delay: 200.ms).fadeOut(duration: 600.ms),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('SELECT A PLANE IN THE AIRSPACE', style: GoogleFonts.inter(color: Colors.white24, fontSize: 10, letterSpacing: 1)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.game.currentLevel.name.toUpperCase(),
                style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildActionBtn(String label, IconData icon, Color color, VoidCallback onPressed, bool isIPad) {
    final isShortScreen = MediaQuery.of(context).size.height < 700;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isIPad ? 24 : (isShortScreen ? 14 : 18)),
      label: Text(label, style: TextStyle(fontSize: isIPad ? 18 : (isShortScreen ? 10 : 12))),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: EdgeInsets.symmetric(
          horizontal: isIPad ? 20 : (isShortScreen ? 8 : 12), 
          vertical: isIPad ? 15 : (isShortScreen ? 6 : 10)
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed, bool isIPad) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: isIPad ? 40 : 28),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
