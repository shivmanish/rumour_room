import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rumour_room/src/core/cubit/paginated_list/paginated_list_state.dart';
import 'package:rumour_room/src/core/network/pagination.dart';
import 'package:rumour_room/src/features/chat/domain/entities/message_entity.dart';
import 'package:rumour_room/src/features/chat/domain/repository/chat_repository.dart';
import 'package:rumour_room/src/features/chat/domain/usecases/load_messages_usecase.dart';
import 'package:rumour_room/src/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:rumour_room/src/features/chat/presentation/cubit/chat/chat_cubit.dart';
import 'package:rumour_room/src/features/join_room/domain/entities/room_entity.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late _MockChatRepository repository;
  late StreamController<List<MessageEntity>> liveController;

  setUp(() {
    repository = _MockChatRepository();
    liveController = StreamController<List<MessageEntity>>();

    when(
      () =>
          repository.streamLatest(roomCode: any(named: 'roomCode'), limit: 30),
    ).thenAnswer((_) => liveController.stream);
    when(
      () => repository.streamRoom(any()),
    ).thenAnswer((_) => Stream.value(const RoomEntity(code: '123456')));
    when(
      () => repository.registerMember(
        roomCode: any(named: 'roomCode'),
        identityId: any(named: 'identityId'),
      ),
    ).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() async {
    await liveController.close();
  });

  ChatCubit buildCubit() {
    return ChatCubit(
      repository: repository,
      loadMessagesUseCase: LoadMessagesUseCase(repository),
      sendMessageUseCase: SendMessageUseCase(repository),
      roomCode: '123456',
      authorId: 'me',
      authorUsername: 'me_user',
    );
  }

  MessageEntity message(String id) {
    return MessageEntity(
      id: id,
      text: 'message $id',
      authorId: id.startsWith('new') ? 'other' : 'me',
      authorUsername: id.startsWith('new') ? 'other_user' : 'me_user',
      sentAt: DateTime(2026, 5, 28, 12),
    );
  }

  test(
    'live updates merge by id without dropping paginated boundary items',
    () async {
      final initial = List<MessageEntity>.generate(
        35,
        (index) => message('old-${index + 1}'),
      );
      final latest = <MessageEntity>[
        message('new-1'),
        message('new-2'),
        ...initial.take(28),
      ];

      when(
        () => repository.loadMessages(
          roomCode: any(named: 'roomCode'),
          pageSize: any(named: 'pageSize'),
          startAfter: any(named: 'startAfter'),
        ),
      ).thenAnswer(
        (_) async => Right(PaginatedResult<MessageEntity>(items: initial)),
      );

      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.loadInitial();
      liveController.add(latest);
      await Future<void>.delayed(Duration.zero);

      final state = cubit.state as PaginatedListLoaded<MessageEntity>;
      final ids = state.items.map((m) => m.id).toList();

      expect(ids, hasLength(37));
      expect(ids.take(2), ['new-1', 'new-2']);
      expect(ids, containsAll(['old-29', 'old-30', 'old-35']));
    },
  );

  test(
    'loadMore advances the cursor and appends the second page',
    () async {
      final firstPage = List<MessageEntity>.generate(
        30,
        (i) => message('p1-${i + 1}'),
      );
      final secondPage = List<MessageEntity>.generate(
        30,
        (i) => message('p2-${i + 1}'),
      );

      final cursor = _StubCursor();
      var call = 0;
      when(
        () => repository.loadMessages(
          roomCode: any(named: 'roomCode'),
          pageSize: any(named: 'pageSize'),
          startAfter: any(named: 'startAfter'),
        ),
      ).thenAnswer((invocation) async {
        call++;
        if (call == 1) {
          return Right(
            PaginatedResult<MessageEntity>(
              items: firstPage,
              nextCursor: cursor,
            ),
          );
        }
        expect(
          invocation.namedArguments[const Symbol('startAfter')],
          same(cursor),
        );
        return Right(
          PaginatedResult<MessageEntity>(items: secondPage),
        );
      });

      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.loadInitial();
      await cubit.loadMore();

      final state = cubit.state as PaginatedListLoaded<MessageEntity>;
      expect(state.items, hasLength(60));
      expect(state.items.first.id, 'p1-1');
      expect(state.items.last.id, 'p2-30');
      expect(state.hasMore, isFalse);
    },
  );
}

class _StubCursor extends PageCursor {}
