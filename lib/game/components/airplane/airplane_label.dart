import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AirplaneLabel extends TextComponent {
  AirplaneLabel({
    required String text,
    required Vector2 position,
  }) : super(
          text: text,
          textRenderer: TextPaint(
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          anchor: Anchor.center,
          position: position,
        );

  void updateText(String flightNumber, String stateName) {
    text = '$flightNumber\n${stateName.toUpperCase()}';
  }

  void hide() {
    text = '';
  }
}
