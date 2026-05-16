import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PersistenceManager {
  static const String _highScoresKey = 'high_scores_';
  static const String _unlockedLevelsKey = 'unlocked_levels';
  static const String _totalLandingsKey = 'total_landings';

  static Future<void> saveScore(String airportId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> scores = await getHighScores(airportId);
    
    scores.add(score);
    scores.sort((a, b) => b.compareTo(a)); // Sort descending
    
    if (scores.length > 5) {
      scores = scores.sublist(0, 5);
    }
    
    await prefs.setString('$_highScoresKey$airportId', jsonEncode(scores));
  }

  static Future<List<int>> getHighScores(String airportId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? scoresJson = prefs.getString('$_highScoresKey$airportId');
    if (scoresJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(scoresJson);
      return decoded.map((e) => e as int).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> incrementTotalLandings(int count) async {
    final prefs = await SharedPreferences.getInstance();
    int total = prefs.getInt(_totalLandingsKey) ?? 0;
    await prefs.setInt(_totalLandingsKey, total + count);
  }

  static Future<int> getTotalLandings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalLandingsKey) ?? 0;
  }

  static Future<void> unlockLevel(String airportId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> unlocked = await getUnlockedLevels();
    if (!unlocked.contains(airportId)) {
      unlocked.add(airportId);
      await prefs.setStringList(_unlockedLevelsKey, unlocked);
    }
  }

  static Future<List<String>> getUnlockedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unlockedLevelsKey) ?? ['LHR']; // Heathrow is always unlocked
  }

  static Future<bool> isLevelUnlocked(String airportId) async {
    if (airportId == 'LHR') return true;
    final unlocked = await getUnlockedLevels();
    return unlocked.contains(airportId);
  }
}
