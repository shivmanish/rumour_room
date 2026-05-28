import 'dart:async';

import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

/// Reactive locale source for MaterialApp. Persists via [LocalStorageService].
class AppLocaleManager with ChangeNotifier {
  AppLocaleManager._();

  static final AppLocaleManager instance = AppLocaleManager._();

  static const String _localeStorageKey = 'rumour.app_locale_code';

  static const List<Locale> _supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  LocalStorageService? _storage;
  Locale _activeLocale = _supportedLocales.first;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  Locale get activeLocale => _activeLocale;
  List<Locale> get supportedLocales => List.unmodifiable(_supportedLocales);

  /// Idempotent. Stored locale wins, else [initialLocale], else the first
  /// supported entry.
  Future<void> initialize(
    LocalStorageService storage, {
    Locale? initialLocale,
  }) async {
    if (_initialized) return;
    _storage = storage;

    final stored = await storage.readString(_localeStorageKey);
    final resolved = _resolveLocale(stored) ??
        _resolveLocale(initialLocale?.languageCode) ??
        _supportedLocales.first;

    _activeLocale = resolved;
    _initialized = true;
  }

  void setLocale(Locale locale) {
    if (!_initialized) {
      throw StateError(
        'AppLocaleManager is not initialized. Call initialize() first.',
      );
    }

    final resolved = _resolveLocale(locale.languageCode);
    if (resolved == null || resolved == _activeLocale) return;

    _activeLocale = resolved;
    notifyListeners();
    unawaited(_persistLocaleCode(resolved.languageCode));
  }

  Locale cycleLocale() {
    if (!_initialized) return _activeLocale;

    final currentIndex = _supportedLocales.indexOf(_activeLocale);
    final nextIndex = (currentIndex + 1) % _supportedLocales.length;
    final next = _supportedLocales[nextIndex];
    setLocale(next);
    return next;
  }

  Locale? _resolveLocale(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) return null;
    for (final locale in _supportedLocales) {
      if (locale.languageCode == languageCode) return locale;
    }
    return null;
  }

  Future<void> _persistLocaleCode(String languageCode) async {
    try {
      await _storage?.writeString(_localeStorageKey, languageCode);
    } catch (_) {
      // best-effort
    }
  }
}
