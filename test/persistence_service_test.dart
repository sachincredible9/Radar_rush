import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:radar_rush/core/services/persistence_service.dart';

void main() {
  group('PersistenceService Tests', () {
    late PersistenceService persistenceService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      persistenceService = PersistenceService(prefs);
    });

    test('Initial total landings should be 0', () {
      expect(persistenceService.getTotalLandings(), 0);
    });

    test('Increment total landings', () async {
      await persistenceService.incrementTotalLandings(5);
      expect(persistenceService.getTotalLandings(), 5);
      
      await persistenceService.incrementTotalLandings(10);
      expect(persistenceService.getTotalLandings(), 15);
    });

    test('Initial unlocked levels should contain LHR', () async {
      final unlocked = await persistenceService.getUnlockedLevels();
      expect(unlocked, contains('LHR'));
    });

    test('Unlock level', () async {
      await persistenceService.unlockLevel('JFK');
      final unlocked = await persistenceService.getUnlockedLevels();
      expect(unlocked, contains('LHR'));
      expect(unlocked, contains('JFK'));
    });

    test('isLevelUnlocked for LHR should always be true', () async {
      expect(await persistenceService.isLevelUnlocked('LHR'), true);
    });

    test('Save and get high scores', () async {
      await persistenceService.saveScore('LHR', 1000);
      await persistenceService.saveScore('LHR', 2000);
      await persistenceService.saveScore('LHR', 500);
      
      final scores = await persistenceService.getHighScores('LHR');
      expect(scores.length, 3);
      expect(scores[0], 2000);
      expect(scores[1], 1000);
      expect(scores[2], 500);
    });

    test('High scores should keep only top 5', () async {
      await persistenceService.saveScore('LHR', 100);
      await persistenceService.saveScore('LHR', 200);
      await persistenceService.saveScore('LHR', 300);
      await persistenceService.saveScore('LHR', 400);
      await persistenceService.saveScore('LHR', 500);
      await persistenceService.saveScore('LHR', 600);
      
      final scores = await persistenceService.getHighScores('LHR');
      expect(scores.length, 5);
      expect(scores, containsAll([600, 500, 400, 300, 200]));
      expect(scores, isNot(contains(100)));
    });
  });
}
