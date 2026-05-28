import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/injector.dart';
import '../localization/app_locale_manager.dart';
import '../network/firebase/firestore_client.dart';
import '../services/local_storage_service.dart';
import '../services/shared_preferences_local_storage.dart';
import '../theme/app_theme_manager.dart';

/// App bootstrap. Called once from main().
class AppInitializer {
  AppInitializer._();
  static final AppInitializer instance = AppInitializer._();

  bool _done = false;

  Future<void> bootstrap() async {
    if (_done) return;
    final stopwatch = Stopwatch()..start();
    debugPrint('[init] start');

    await _lockOrientation();
    await _initFirebase();
    final LocalStorageService storage = SharedPreferencesLocalStorage(
      await SharedPreferences.getInstance(),
    );
    await initInjector(storage: storage);
    await sl<FirestoreClient>().enablePersistence();
    await AppLocaleManager.instance.initialize(storage);
    await AppThemeManager.instance.initialize(storage);

    _done = true;
    debugPrint('[init] done in ${stopwatch.elapsed.inMilliseconds}ms');
  }

  Future<void> _lockOrientation() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp();
    } on FirebaseException catch (e) {
      // duplicate-app happens on hot restart — safe to ignore.
      if (e.code != 'duplicate-app') rethrow;
    }
  }
}
