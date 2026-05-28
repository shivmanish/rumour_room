import 'package:dartz/dartz.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

/// Wraps a body in try/catch and maps typed exceptions to Failures.
mixin ResultGuard {
  Future<Either<Failure, T>> guard<T>(Future<T> Function() body) async {
    try {
      final result = await body();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        return Left(AuthFailure(e.message));
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
