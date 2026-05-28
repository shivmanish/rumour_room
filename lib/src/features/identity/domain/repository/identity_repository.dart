import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/identity_entity.dart';

abstract class IdentityRepository {
  /// Idempotent per room: cache hit, else fetch + cache.
  Future<Either<Failure, ResolvedIdentity>> getOrFetch(String roomCode);
}

class ResolvedIdentity {
  const ResolvedIdentity({required this.identity, required this.isFresh});

  final IdentityEntity identity;

  /// true only on a fresh fetch — drives the reveal overlay.
  final bool isFresh;
}
