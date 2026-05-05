import 'package:flame/components.dart';

class Runway {
  final Vector2 start;
  final Vector2 end;
  final String label;

  Runway({required this.start, required this.end, required this.label});
}

class GateConfig {
  final Vector2 position;
  final String label;
  GateConfig({required this.position, required this.label});
}

class LevelConfig {
  final String name;
  final String country;
  final String iataCode;
  final String backgroundImage;
  final List<Runway> runways;
  final Vector2 taxiToGate;
  final List<GateConfig> gates;

  LevelConfig({
    required this.name,
    required this.country,
    required this.iataCode,
    required this.backgroundImage,
    required this.runways,
    required this.taxiToGate,
    required this.gates,
  });

  static List<LevelConfig> allLevels = [
    LevelConfig(
      name: 'Heathrow Airport',
      country: 'UK',
      iataCode: 'LHR',
      backgroundImage: 'airport_london.jpg',
      runways: [
        Runway(start: Vector2(100, 350), end: Vector2(900, 350), label: '09L'),
        Runway(start: Vector2(100, 450), end: Vector2(900, 450), label: '09R'),
      ],
      taxiToGate: Vector2(500, 250),
      gates: [
        GateConfig(position: Vector2(300, 150), label: 'G1'),
        GateConfig(position: Vector2(400, 150), label: 'G2'),
        GateConfig(position: Vector2(500, 150), label: 'G3'),
        GateConfig(position: Vector2(600, 150), label: 'G4'),
        GateConfig(position: Vector2(700, 150), label: 'G5'),
      ],
    ),
    LevelConfig(
      name: 'JFK International',
      country: 'USA',
      iataCode: 'JFK',
      backgroundImage: 'airport_usa.jpg',
      runways: [
        Runway(start: Vector2(100, 200), end: Vector2(900, 600), label: '13L'),
        Runway(start: Vector2(100, 400), end: Vector2(900, 800), label: '31R'),
      ],
      taxiToGate: Vector2(500, 450),
      gates: [
        GateConfig(position: Vector2(400, 300), label: 'G1'),
        GateConfig(position: Vector2(500, 300), label: 'G2'),
        GateConfig(position: Vector2(600, 300), label: 'G3'),
        GateConfig(position: Vector2(400, 400), label: 'G4'),
        GateConfig(position: Vector2(500, 400), label: 'G5'),
      ],
    ),
    LevelConfig(
      name: 'Indira Gandhi Intl',
      country: 'India',
      iataCode: 'DEL',
      backgroundImage: 'airport_india.jpg',
      runways: [
        Runway(start: Vector2(100, 600), end: Vector2(900, 600), label: '10/28'),
        Runway(start: Vector2(100, 700), end: Vector2(900, 700), label: '11/29'),
      ],
      taxiToGate: Vector2(500, 400),
      gates: [GateConfig(position: Vector2(400, 200), label: "G1"), GateConfig(position: Vector2(500, 200), label: "G2"), GateConfig(position: Vector2(600, 200), label: "G3")],
    ),
    LevelConfig(
      name: 'Dubai International',
      country: 'UAE',
      iataCode: 'DXB',
      backgroundImage: 'airport_uae.jpg',
      runways: [
        Runway(start: Vector2(50, 400), end: Vector2(950, 400), label: '12L'),
        Runway(start: Vector2(50, 500), end: Vector2(950, 500), label: '12R'),
      ],
      taxiToGate: Vector2(500, 250),
      gates: [
        GateConfig(position: Vector2(300, 150), label: 'G1'),
        GateConfig(position: Vector2(400, 150), label: 'G2'),
        GateConfig(position: Vector2(500, 150), label: 'G3'),
        GateConfig(position: Vector2(600, 150), label: 'G4'),
      ],
    ),
    LevelConfig(
      name: 'Changi Airport',
      country: 'Singapore',
      iataCode: 'SIN',
      backgroundImage: 'airport_singapore.jpg',
      runways: [
        Runway(start: Vector2(100, 200), end: Vector2(900, 200), label: '02L'),
        Runway(start: Vector2(100, 300), end: Vector2(900, 300), label: '02R'),
      ],
      taxiToGate: Vector2(500, 400),
      gates: [GateConfig(position: Vector2(300, 500), label: "G1"), GateConfig(position: Vector2(350, 500), label: "G2"), GateConfig(position: Vector2(400, 500), label: "G3"), GateConfig(position: Vector2(450, 500), label: "G4"), GateConfig(position: Vector2(500, 500), label: "G5"), GateConfig(position: Vector2(550, 500), label: "G6"), GateConfig(position: Vector2(300, 550), label: "G7"), GateConfig(position: Vector2(350, 550), label: "G8"), GateConfig(position: Vector2(400, 550), label: "G9"), GateConfig(position: Vector2(450, 550), label: "G10"), GateConfig(position: Vector2(500, 550), label: "G11"), GateConfig(position: Vector2(550, 550), label: "G12")],
    ),
    LevelConfig(
      name: 'Haneda Airport',
      country: 'Japan',
      iataCode: 'HND',
      backgroundImage: 'airport_japan.jpg',
      runways: [
        Runway(start: Vector2(200, 100), end: Vector2(200, 900), label: '16R'),
        Runway(start: Vector2(300, 100), end: Vector2(300, 900), label: '16L'),
      ],
      taxiToGate: Vector2(400, 500),
      gates: [GateConfig(position: Vector2(600, 300), label: "G1"), GateConfig(position: Vector2(600, 350), label: "G2"), GateConfig(position: Vector2(600, 400), label: "G3"), GateConfig(position: Vector2(600, 450), label: "G4"), GateConfig(position: Vector2(600, 500), label: "G5"), GateConfig(position: Vector2(600, 550), label: "G6"), GateConfig(position: Vector2(650, 300), label: "G7"), GateConfig(position: Vector2(650, 350), label: "G8"), GateConfig(position: Vector2(650, 400), label: "G9"), GateConfig(position: Vector2(650, 450), label: "G10"), GateConfig(position: Vector2(650, 500), label: "G11"), GateConfig(position: Vector2(650, 550), label: "G12")],
    ),
    LevelConfig(
      name: 'Charles de Gaulle',
      country: 'France',
      iataCode: 'CDG',
      backgroundImage: 'airport_france.jpg',
      runways: [
        Runway(start: Vector2(100, 300), end: Vector2(900, 300), label: '08L'),
        Runway(start: Vector2(100, 400), end: Vector2(900, 400), label: '08R'),
      ],
      taxiToGate: Vector2(500, 500),
      gates: [GateConfig(position: Vector2(400, 600), label: "G1"), GateConfig(position: Vector2(450, 600), label: "G2"), GateConfig(position: Vector2(500, 600), label: "G3"), GateConfig(position: Vector2(550, 600), label: "G4"), GateConfig(position: Vector2(600, 600), label: "G5"), GateConfig(position: Vector2(650, 600), label: "G6"), GateConfig(position: Vector2(400, 650), label: "G7"), GateConfig(position: Vector2(450, 650), label: "G8"), GateConfig(position: Vector2(500, 650), label: "G9"), GateConfig(position: Vector2(550, 650), label: "G10"), GateConfig(position: Vector2(600, 650), label: "G11"), GateConfig(position: Vector2(650, 650), label: "G12")],
    ),
    LevelConfig(
      name: 'Sydney Airport',
      country: 'Australia',
      iataCode: 'SYD',
      backgroundImage: 'airport_australia.jpg',
      runways: [
        Runway(start: Vector2(500, 100), end: Vector2(500, 900), label: '16L'),
        Runway(start: Vector2(600, 100), end: Vector2(600, 900), label: '16R'),
      ],
      taxiToGate: Vector2(300, 500),
      gates: [GateConfig(position: Vector2(100, 300), label: "G1"), GateConfig(position: Vector2(100, 350), label: "G2"), GateConfig(position: Vector2(100, 400), label: "G3"), GateConfig(position: Vector2(100, 450), label: "G4"), GateConfig(position: Vector2(100, 500), label: "G5"), GateConfig(position: Vector2(100, 550), label: "G6"), GateConfig(position: Vector2(150, 300), label: "G7"), GateConfig(position: Vector2(150, 350), label: "G8"), GateConfig(position: Vector2(150, 400), label: "G9"), GateConfig(position: Vector2(150, 450), label: "G10"), GateConfig(position: Vector2(150, 500), label: "G11"), GateConfig(position: Vector2(150, 550), label: "G12")],
    ),
    LevelConfig(
      name: 'Frankfurt Airport',
      country: 'Germany',
      iataCode: 'FRA',
      backgroundImage: 'airport_germany.jpg',
      runways: [
        Runway(start: Vector2(100, 400), end: Vector2(900, 400), label: '07C'),
        Runway(start: Vector2(100, 500), end: Vector2(900, 500), label: '07R'),
      ],
      taxiToGate: Vector2(500, 600),
      gates: [GateConfig(position: Vector2(300, 800), label: "G1"), GateConfig(position: Vector2(350, 800), label: "G2"), GateConfig(position: Vector2(400, 800), label: "G3"), GateConfig(position: Vector2(450, 800), label: "G4"), GateConfig(position: Vector2(500, 800), label: "G5"), GateConfig(position: Vector2(550, 800), label: "G6"), GateConfig(position: Vector2(300, 850), label: "G7"), GateConfig(position: Vector2(350, 850), label: "G8"), GateConfig(position: Vector2(400, 850), label: "G9"), GateConfig(position: Vector2(450, 850), label: "G10"), GateConfig(position: Vector2(500, 850), label: "G11"), GateConfig(position: Vector2(550, 850), label: "G12")],
    ),
    LevelConfig(
      name: 'Suvarnabhumi',
      country: 'Thailand',
      iataCode: 'BKK',
      backgroundImage: 'airport_thailand.jpg',
      runways: [
        Runway(start: Vector2(200, 200), end: Vector2(800, 800), label: '01L'),
        Runway(start: Vector2(300, 100), end: Vector2(900, 700), label: '01R'),
      ],
      taxiToGate: Vector2(500, 500),
      gates: [GateConfig(position: Vector2(700, 200), label: "G1"), GateConfig(position: Vector2(750, 200), label: "G2"), GateConfig(position: Vector2(800, 200), label: "G3"), GateConfig(position: Vector2(850, 200), label: "G4"), GateConfig(position: Vector2(700, 250), label: "G5"), GateConfig(position: Vector2(750, 250), label: "G6"), GateConfig(position: Vector2(800, 250), label: "G7"), GateConfig(position: Vector2(850, 250), label: "G8"), GateConfig(position: Vector2(700, 300), label: "G9"), GateConfig(position: Vector2(750, 300), label: "G10"), GateConfig(position: Vector2(800, 300), label: "G11"), GateConfig(position: Vector2(850, 300), label: "G12")],
    ),
  ];
}
