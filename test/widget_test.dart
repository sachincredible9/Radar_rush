import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:radar_rush/core/service_locator.dart';
import 'package:radar_rush/core/services/persistence_service.dart';
import 'package:radar_rush/core/services/audio_service.dart';
import 'package:radar_rush/core/services/auth_service.dart';
import 'package:radar_rush/core/services/analytics_service.dart';
import 'package:radar_rush/main.dart';

class MockAuthService implements AuthService {
  @override
  User? get currentUser => null;

  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithEmail(String email, String password) async => null;

  @override
  Future<User?> registerWithEmail(String email, String password) async => null;

  @override
  Future<void> signOut() async {}
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    
    // Register mock/real dependencies directly to GetIt to avoid calling the real AuthService constructor
    getIt.registerSingleton<PersistenceService>(PersistenceService(sharedPreferences));
    getIt.registerSingleton<AudioService>(AudioService());
    getIt.registerSingleton<AuthService>(MockAuthService());
    getIt.registerSingleton<AnalyticsService>(AnalyticsService());
  });

  testWidgets('App should load', (WidgetTester tester) async {
    await tester.pumpWidget(const GameApp());
    expect(find.byType(GameApp), findsOneWidget);
  });
}
