// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ChatScreen]
class ChatRoute extends PageRouteInfo<ChatRouteArgs> {
  ChatRoute({Key? key, required String roomCode, List<PageRouteInfo>? children})
    : super(
        ChatRoute.name,
        args: ChatRouteArgs(key: key, roomCode: roomCode),
        rawPathParams: {'roomCode': roomCode},
        initialChildren: children,
      );

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatRouteArgs>(
        orElse: () => ChatRouteArgs(roomCode: pathParams.getString('roomCode')),
      );
      return ChatScreen(key: args.key, roomCode: args.roomCode);
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({this.key, required this.roomCode});

  final Key? key;

  final String roomCode;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, roomCode: $roomCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return key == other.key && roomCode == other.roomCode;
  }

  @override
  int get hashCode => key.hashCode ^ roomCode.hashCode;
}

/// generated route for
/// [JoinRoomScreen]
class JoinRoute extends PageRouteInfo<void> {
  const JoinRoute({List<PageRouteInfo>? children})
    : super(JoinRoute.name, initialChildren: children);

  static const String name = 'JoinRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const JoinRoomScreen();
    },
  );
}
