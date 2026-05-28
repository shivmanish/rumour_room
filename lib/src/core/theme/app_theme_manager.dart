import 'dart:async';

import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

/// Persisted ThemeMode source for MaterialApp.
class AppThemeManager with ChangeNotifier {
  AppThemeManager._();

  static final AppThemeManager instance = AppThemeManager._();

  static const String _storageKey = 'rumour.theme_mode';

  LocalStorageService? _storage;
  ThemeMode _activeMode = ThemeMode.dark;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  ThemeMode get activeMode => _activeMode;

  Future<void> initialize(LocalStorageService storage) async {
    if (_initialized) return;
    _storage = storage;
    final stored = await storage.readString(_storageKey);
    _activeMode = _decode(stored) ?? ThemeMode.dark;
    _initialized = true;
  }

  void setMode(ThemeMode mode) {
    if (!_initialized) {
      throw StateError(
        'AppThemeManager is not initialized. Call initialize() first.',
      );
    }
    if (mode == _activeMode) return;
    _activeMode = mode;
    notifyListeners();
    unawaited(_persist(mode));
  }

  void toggleLightDark() {
    setMode(_activeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  ThemeMode cycle() {
    const order = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    final next = order[(order.indexOf(_activeMode) + 1) % order.length];
    setMode(next);
    return next;
  }

  Future<void> _persist(ThemeMode mode) async {
    try {
      await _storage?.writeString(_storageKey, mode.name);
    } catch (_) {
      // best-effort
    }
  }

  ThemeMode? _decode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
}
