import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/result_guard.dart';
import '../../domain/repository/identity_repository.dart';
import '../datasource/identity_local_datasource.dart';
import '../datasource/identity_remote_datasource.dart';

class IdentityRepositoryImpl with ResultGuard implements IdentityRepository {
  IdentityRepositoryImpl({
    required this.remote,
    required this.local,
    required this.connectivity,
  });

  final IdentityRemoteDataSource remote;
  final IdentityLocalDataSource local;
  final ConnectivityService connectivity;

  @override
  Future<Either<Failure, ResolvedIdentity>> getOrFetch(String roomCode) {
    return guard<ResolvedIdentity>(() async {
      final cached = await local.read(roomCode);
      if (cached != null) {
        return ResolvedIdentity(identity: cached, isFresh: false);
      }
      // no cache → API is the only path. short-circuit when offline so we
      // don't sit on Dio's connect timeout
      final status = await connectivity.currentStatus();
      if (status == ConnectivityStatus.offline) {
        throw NetworkException('You are offline.');
      }
      final fetched = await remote.fetchRandomIdentity();
      await local.write(roomCode: roomCode, identity: fetched);
      return ResolvedIdentity(identity: fetched, isFresh: true);
    });
  }
}
