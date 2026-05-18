import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/persistence_service.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'services/analytics_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<PersistenceService>(PersistenceService(sharedPreferences));
  
  getIt.registerSingleton<AudioService>(AudioService());
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<AnalyticsService>(AnalyticsService());
}
