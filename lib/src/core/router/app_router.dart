import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/join_room/presentation/screens/join_room_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: JoinRoute.page, path: '/', initial: true),
        AutoRoute(page: ChatRoute.page, path: '/chat/:roomCode'),
      ];
}
