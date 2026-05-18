import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PersistenceService {
  final SharedPreferences _prefs;

  PersistenceService(this._prefs);

  static const String _highScoresKey = 'high_scores_';
  static const String _unlockedLevelsKey = 'unlocked_levels';
  static const String _totalLandingsKey = 'total_landings';

  Future<void> saveScore(String airportId, int score) async {
    List<int> scores = await getHighScores(airportId);
    
    scores.add(score);
    scores.sort((a, b) => b.compareTo(a)); // Sort descending
    
    if (scores.length > 5) {
      scores = scores.sublist(0, 5);
    }
    
    await _prefs.setString('$_highScoresKey$airportId', jsonEncode(scores));
  }

  Future<List<int>> getHighScores(String airportId) async {
    final String? scoresJson = _prefs.getString('$_highScoresKey$airportId');
    if (scoresJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(scoresJson);
      return decoded.map((e) => e as int).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> incrementTotalLandings(int count) async {
    int total = _prefs.getInt(_totalLandingsKey) ?? 0;
    await _prefs.setInt(_totalLandingsKey, total + count);
  }

  int getTotalLandings() {
    return _prefs.getInt(_totalLandingsKey) ?? 0;
  }

  Future<void> unlockLevel(String airportId) async {
    List<String> unlocked = await getUnlockedLevels();
    if (!unlocked.contains(airportId)) {
      unlocked.add(airportId);
      await _prefs.setStringList(_unlockedLevelsKey, unlocked);
    }
  }

  Future<List<String>> getUnlockedLevels() async {
    return _prefs.getStringList(_unlockedLevelsKey) ?? ['LHR']; // Heathrow is always unlocked
  }

  Future<bool> isLevelUnlocked(String airportId) async {
    if (airportId == 'LHR') return true;
    final unlocked = await getUnlockedLevels();
    return unlocked.contains(airportId);
  }
}
