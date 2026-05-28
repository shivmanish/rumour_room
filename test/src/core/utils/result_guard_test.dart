import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rumour_room/src/core/error/exceptions.dart';
import 'package:rumour_room/src/core/error/failures.dart';
import 'package:rumour_room/src/core/utils/result_guard.dart';

class _Guard with ResultGuard {}

void main() {
  final guard = _Guard();

  group('ResultGuard', () {
    test('returns Right(value) when the body completes', () async {
      final result = await guard.guard<int>(() async => 42);
      expect(result, equals(const Right<Failure, int>(42)));
    });

    test('maps NetworkException → NetworkFailure', () async {
      final result = await guard.guard<int>(
        () async => throw NetworkException('offline'),
      );
      expect(
        result,
        equals(const Left<Failure, int>(NetworkFailure('offline'))),
      );
    });

    test('maps AuthException → AuthFailure', () async {
      final result = await guard.guard<int>(
        () async => throw AuthException('unauthorized'),
      );
      expect(
        result,
        equals(const Left<Failure, int>(AuthFailure('unauthorized'))),
      );
    });

    test('maps NotFoundException → NotFoundFailure', () async {
      final result = await guard.guard<int>(
        () async => throw NotFoundException('missing'),
      );
      expect(
        result,
        equals(const Left<Failure, int>(NotFoundFailure('missing'))),
      );
    });

    test('maps FirestoreException → FirestoreFailure', () async {
      final result = await guard.guard<int>(
        () async => throw FirestoreException('fs'),
      );
      expect(
        result,
        equals(const Left<Failure, int>(FirestoreFailure('fs'))),
      );
    });

    test('maps CacheException → CacheFailure', () async {
      final result = await guard.guard<int>(
        () async => throw CacheException('cache'),
      );
      expect(result, equals(const Left<Failure, int>(CacheFailure('cache'))));
    });

    test('maps 401 ServerException → AuthFailure', () async {
      final result = await guard.guard<int>(
        () async => throw ServerException('unauth', statusCode: 401),
      );
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<AuthFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('maps 403 ServerException → AuthFailure', () async {
      final result = await guard.guard<int>(
        () async => throw ServerException('forbidden', statusCode: 403),
      );
      result.fold(
        (f) => expect(f, isA<AuthFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('maps other ServerException → NetworkFailure', () async {
      final result = await guard.guard<int>(
        () async => throw ServerException('500', statusCode: 500),
      );
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('maps anything else → UnknownFailure', () async {
      final result = await guard.guard<int>(
        () async => throw StateError('boom'),
      );
      result.fold(
        (f) => expect(f, isA<UnknownFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
