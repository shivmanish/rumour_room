import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rumour_room/src/core/error/exceptions.dart';
import 'package:rumour_room/src/core/error/failures.dart';
import 'package:rumour_room/src/core/services/connectivity_service.dart';
import 'package:rumour_room/src/features/identity/data/datasource/identity_local_datasource.dart';
import 'package:rumour_room/src/features/identity/data/datasource/identity_remote_datasource.dart';
import 'package:rumour_room/src/features/identity/data/models/identity_model.dart';
import 'package:rumour_room/src/features/identity/data/repository_impl/identity_repository_impl.dart';
import 'package:rumour_room/src/features/identity/domain/repository/identity_repository.dart';

class _MockRemote extends Mock implements IdentityRemoteDataSource {}

class _MockLocal extends Mock implements IdentityLocalDataSource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

class _FakeIdentity extends Fake implements IdentityModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeIdentity());
  });

  late _MockRemote remote;
  late _MockLocal local;
  late _MockConnectivity connectivity;
  late IdentityRepositoryImpl repo;

  const roomCode = '123456';
  const fetched = IdentityModel(
    id: 'uuid-1',
    displayName: 'Brave Badger',
    username: 'bravebadger',
  );

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    connectivity = _MockConnectivity();
    repo = IdentityRepositoryImpl(
      remote: remote,
      local: local,
      connectivity: connectivity,
    );
  });

  group('getOrFetch — cache hit', () {
    test('returns ResolvedIdentity(isFresh: false) without touching remote',
        () async {
      when(() => local.read(roomCode)).thenAnswer((_) async => fetched);

      final result = await repo.getOrFetch(roomCode);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (resolved) {
          expect(resolved.identity, equals(fetched));
          expect(resolved.isFresh, isFalse);
        },
      );
      verifyNever(() => remote.fetchRandomIdentity());
      verifyNever(() => connectivity.currentStatus());
      verifyNever(
        () => local.write(
          roomCode: any(named: 'roomCode'),
          identity: any(named: 'identity'),
        ),
      );
    });
  });

  group('getOrFetch — cache miss + online', () {
    test('fetches, writes cache, returns ResolvedIdentity(isFresh: true)',
        () async {
      when(() => local.read(roomCode)).thenAnswer((_) async => null);
      when(() => connectivity.currentStatus())
          .thenAnswer((_) async => ConnectivityStatus.online);
      when(() => remote.fetchRandomIdentity()).thenAnswer((_) async => fetched);
      when(
        () => local.write(
          roomCode: any(named: 'roomCode'),
          identity: any(named: 'identity'),
        ),
      ).thenAnswer((_) async {});

      final result = await repo.getOrFetch(roomCode);

      result.fold(
        (_) => fail('expected Right'),
        (resolved) {
          expect(resolved.identity, equals(fetched));
          expect(resolved.isFresh, isTrue);
        },
      );
      verify(
        () => local.write(roomCode: roomCode, identity: fetched),
      ).called(1);
    });

    test('still returns the fetched identity even if cache write throws',
        () async {
      when(() => local.read(roomCode)).thenAnswer((_) async => null);
      when(() => connectivity.currentStatus())
          .thenAnswer((_) async => ConnectivityStatus.online);
      when(() => remote.fetchRandomIdentity()).thenAnswer((_) async => fetched);
      when(
        () => local.write(
          roomCode: any(named: 'roomCode'),
          identity: any(named: 'identity'),
        ),
      ).thenThrow(CacheException('disk full'));

      final result = await repo.getOrFetch(roomCode);

      expect(result.isRight(), isTrue,
          reason: 'cache write failure must not drop a successful fetch');
      result.fold(
        (_) => fail('expected Right'),
        (resolved) {
          expect(resolved.identity, equals(fetched));
          expect(resolved.isFresh, isTrue);
        },
      );
    });
  });

  group('getOrFetch — cache miss + offline', () {
    test(
        'short-circuits with NetworkFailure and does not call the remote',
        () async {
      when(() => local.read(roomCode)).thenAnswer((_) async => null);
      when(() => connectivity.currentStatus())
          .thenAnswer((_) async => ConnectivityStatus.offline);

      final result = await repo.getOrFetch(roomCode);

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(() => remote.fetchRandomIdentity());
      verifyNever(
        () => local.write(
          roomCode: any(named: 'roomCode'),
          identity: any(named: 'identity'),
        ),
      );
    });
  });

  group('ResolvedIdentity equality', () {
    test('values compare equal by identity + isFresh', () {
      const a = ResolvedIdentity(identity: fetched, isFresh: true);
      const b = ResolvedIdentity(identity: fetched, isFresh: true);
      const c = ResolvedIdentity(identity: fetched, isFresh: false);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
