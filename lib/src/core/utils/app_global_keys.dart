import 'package:flutter/material.dart';

/// Root-level keys for navigator/messenger so non-widget code can reach them.
class AppGlobalKeys {
  AppGlobalKeys._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}
