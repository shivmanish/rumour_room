import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/core/utils/app_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.instance.bootstrap();
  runApp(const App());
}
