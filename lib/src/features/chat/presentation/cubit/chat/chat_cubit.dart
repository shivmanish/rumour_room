// ignore_for_file: prefer_initializing_formals
// Reason: dependency fields are private (`_repository`, `_loadMessages`,
// `_sendMessage`); using `required this._repository` would force the
// private name into the API. Named public params + explicit field
// assignment keeps the constructor readable.

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/cubit/paginated_list/paginated_list_cubit.dart';
import '../../../../../core/cubit/paginated_list/paginated_list_state.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/pagination.dart';
import '../../../../join_room/domain/entities/room_entity.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repository/chat_repository.dart';
import '../../../domain/usecases/load_messages_usecase.dart';
import '../../../domain/usecases/send_message_usecase.dart';

class ChatCubit extends PaginatedListCubit<MessageEntity> {
  ChatCubit({
    required ChatRepository repository,
    required LoadMessagesUseCase loadMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required this.roomCode,
    required this.authorId,
    required this.authorUsername,
  }) : _repository = repository,
       _loadMessages = loadMessagesUseCase,
       _sendMessage = sendMessageUseCase,
       super(pageSize: _pageSize) {
    _knownMemberIds.add(authorId);
    _publishMemberCount();
    _subscribeMessages();
    _subscribeRoom();
    _registerMember();
  }

  static const int _pageSize = 30;
  static const int _liveWindowSize = _pageSize;

  final ChatRepository _repository;
  final LoadMessagesUseCase _loadMessages;
  final SendMessageUseCase _sendMessage;

  final String roomCode;
  final String authorId;
  final String authorUsername;

  StreamSubscription<List<MessageEntity>>? _liveSub;
  StreamSubscription<RoomEntity?>? _roomSub;
  final Set<String> _knownMemberIds = <String>{};
  final Set<String> _roomMemberIds = <String>{};
  final Set<String> _memberBackfillRequestedIds = <String>{};

  /// member count; ValueNotifier so app bar rebuilds independently
  final ValueNotifier<int> memberCount = ValueNotifier<int>(0);

  void _subscribeMessages() {
    _liveSub = _repository
        .streamLatest(roomCode: roomCode, limit: _liveWindowSize)
        .listen(
          _onLiveUpdate,
          onError: (Object error, StackTrace stack) {
            if (isClosed) return;
            emit(
              PaginatedListError<MessageEntity>(
                UnknownFailure(error.toString()),
                items: state.items,
                hasMore: state.hasMore,
              ),
            );
          },
        );
  }

  void _subscribeRoom() {
    _roomSub = _repository.streamRoom(roomCode).listen((room) {
      if (room == null) return;
      _roomMemberIds
        ..clear()
        ..addAll(room.memberIds.where((id) => id.isNotEmpty));
      _knownMemberIds.addAll(_roomMemberIds);
      _publishMemberCount();
    });
  }

  /// fire-and-forget — chat works regardless of whether count updates
  void _registerMember() {
    _memberBackfillRequestedIds.add(authorId);
    unawaited(
      _repository.registerMember(roomCode: roomCode, identityId: authorId),
    );
  }

  // merge by id so live updates don't drop paginated history at the boundary
  void _onLiveUpdate(List<MessageEntity> latest) {
    if (isClosed) return;
    _rememberMessageAuthors(latest);
    final current = state;
    if (current is! PaginatedListLoaded<MessageEntity>) return;

    emit(
      PaginatedListLoaded<MessageEntity>(
        items: List.unmodifiable(_mergeLatest(latest, current.items)),
        hasMore: current.hasMore,
      ),
    );
  }

  List<MessageEntity> _mergeLatest(
    List<MessageEntity> latest,
    List<MessageEntity> current,
  ) {
    final latestIds = latest.map((m) => m.id).toSet();
    return <MessageEntity>[
      ...latest,
      for (final message in current)
        if (!latestIds.contains(message.id)) message,
    ];
  }

  void _rememberMessageAuthors(List<MessageEntity> messages) {
    for (final message in messages) {
      final id = message.authorId;
      if (id.isEmpty) continue;
      _knownMemberIds.add(id);
      if (_roomMemberIds.contains(id)) continue;
      if (!_memberBackfillRequestedIds.add(id)) continue;
      unawaited(_repository.registerMember(roomCode: roomCode, identityId: id));
    }
    _publishMemberCount();
  }

  void _publishMemberCount() {
    memberCount.value = _knownMemberIds.length;
  }

  @override
  Future<Either<Failure, PaginatedResult<MessageEntity>>> fetchPage(
    PageCursor? cursor,
  ) {
    return _loadMessages.call(
      LoadMessagesParams(
        roomCode: roomCode,
        pageSize: pageSize,
        startAfter: cursor,
      ),
    );
  }

  Future<Either<Failure, Unit>> send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Future.value(const Right(unit));

    return _sendMessage.call(
      SendMessageParams(
        roomCode: roomCode,
        text: trimmed,
        authorId: authorId,
        authorUsername: authorUsername,
      ),
    );
  }

  bool isMyMessage(MessageEntity m) => m.authorId == authorId;

  @override
  Future<void> close() {
    _liveSub?.cancel();
    _roomSub?.cancel();
    memberCount.dispose();
    return super.close();
  }
}
